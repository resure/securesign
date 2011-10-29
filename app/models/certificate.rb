class Certificate < ActiveRecord::Base
  include DigestMethods
  
  belongs_to :user
  belongs_to :certificate
  belongs_to :key
  has_many :certificates
  has_many :signs
  
  before_destroy :ensure_not_referenced_by_any_object
  
  attr_accessible :body, :title, :key_id, :certificate_id, :key_password,
    :common_name, :organization, :organization_unit, :country, :days, :locality, :email, :state
    
  attr_accessor :key_password
  
  before_validation :check_certificate_id, :set_user_id, :set_days, :set_key
  
  after_create :set_serial_number, :set_parent_certificate_owner_id
  
  validates_associated :user
  validates_associated :key
  
  validates :title, :common_name, length: { within: 3..254 }
  validates :country, length: { maximum: 2 }
  validates :user_id, :key_id, :days, presence: true, numericality: { only_integer: true, minimum: 1 }
  validates :certificate_id, presence: true, numericality: { only_integer: true, minimum: 0 }
  
  validates :certificate_id, issuing_by_ca: true
  
  validates :email, :common_name, :organization, :organization_unit, :country, :locality, :state,
    length: { maximum: 255 },
    format: { with: /^[^\/]*$/, message: "Slash is not allowed" }
    
  validates :email, email: true
  validates :key_password, key_password: true
  
  def generate_certificate(key_password)
    certificate_data = openssl_generate_certificate(key_password)
    
    self.update_attribute(:body, certificate_data)
    
    if selfsigned?
      self.update_attribute(:ca, true)
      self.update_attribute(:request_status, 1)
    else
      self.update_attribute(:request_status, 2)
    end
    
    generate_digest
    true
  end
  
  def sign_certificate(key_password, request_id = self.id, days = 365, create_ca)
    request = Certificate.find(request_id)
    
    if request.certificate_id != self.id or !self.ca or request.request_status != 2
      request.update_attribute(:request_status, 4)
      return false
    end
    
    request_data = openssl_sign_certificate(key_password, request_id, create_ca)
    
    update_attribute(:serial, serial + 1) if request_data != 'OpenSSL error'
    request.update_attribute(:body, request_data)
    request.update_attribute(:request_status, 3)
    request.generate_digest
    request.update_attribute(:ca, true) if create_ca
    true
  end
  
  def selfsigned?
    self.certificate_id == 0
  end
  
  def ca?
    self.ca == true
  end
  
  def issued_by
    @issued_by ||= self.certificate
  end
  
  
  private
  
  def check_certificate_id
    self.certificate_id ||= 0
    self.certificate_id = 0 if self.certificate_id < 0
  end
  
  def set_user_id
    self.user_id ||= User.first.id
  end
  
  def set_serial_number
    self.update_attribute(:serial, 0)
  end
  
  def set_parent_certificate_owner_id
    if self.certificate_id == 0
      self.update_attribute(:parent_certificate_owner_id, self.user_id)
    else
      self.update_attribute(:parent_certificate_owner_id, self.certificate.user_id)
    end
  end
  
  def set_days
    self.days = 1 if !self.days || self.days < 1
  end
  
  def set_key
    if !self.key_id || self.key_id < 1
      errors.add(:base, 'Invalid key id')
    elsif Key.find(self.key_id).user_id != self.user_id && Rails.env != 'test'
      errors.add(:base, 'Key isn\'t yours')
    end
  end
  
  def openssl_generate_certificate(key_password)
    key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    certificate_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    
    attempts = 0
    
    query = "openssl req -new"
    query += " -x509" if selfsigned?
    query += " -key #{key_file}"
    query += " -days #{days}" if selfsigned? and !days.blank?
    query += " -subj '/"
    query += "CN=#{common_name}/" unless common_name.blank?
    query += "C=#{country}/" unless country.blank?
    query += "ST=#{state}/" unless state.blank?
    query += "L=#{locality}/" unless locality.blank?
    query += "O=#{organization}/" unless organization.blank?
    query += "OU=#{organization_unit}/" unless organization_unit.blank?
    query += "emailAddress=#{email}/" unless email.blank?
    query += "' > #{certificate_file}"
    
    require "pty"
    require "expect"
    
    certificate_data = ''
    while certificate_data.blank?
      `echo "#{key.body}" > #{key_file}`
      
      PTY.spawn(query) do |reader, writer|
        reader.expect(/Enter pass/)
        writer.puts("#{key_password}\n")
      end
      
      certificate_data = `cat #{certificate_file}`
      
      `rm #{key_file}`
      `rm #{certificate_file}`
      
      attempts += 1
      if attempts > 100
        certificate_data = 'OpenSSL error'
      end
    end
    
    certificate_data
  end
  
  def openssl_sign_certificate(key_password, request_id, create_ca = false)
    key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    certificate_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    request_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    result_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    config_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64 if create_ca
    
    request = Certificate.find(request_id)
    
    attempts = 0
    
    query =   "openssl x509"
    query +=  " -req"
    query +=  " -days #{days}"
    query +=  " -in #{request_file}"
    query +=  " -CA #{certificate_file}"
    query +=  " -CAkey #{key_file}"
    query +=  " -set_serial #{self.serial}"
    query +=  " -out #{result_file}"
    query +=  " -extfile #{config_file}"    if create_ca
    query +=  " -extensions v3_req"         if create_ca
    
    require "pty"
    require "expect"
    
    request_data = ''
    while request_data.blank?
      `echo '#{key.body}' > #{key_file}`
      `echo '#{request.body}' > #{request_file}`
      `echo '#{body}' > #{certificate_file}`
      `echo '[v3_req]\nbasicConstraints=CA:true' > #{config_file}` if create_ca
      
      PTY.spawn(query) do |reader, writer|        
        reader.expect(/Enter pass/)
        writer.puts("#{key_password}\n")
      end
      
      request_data = `cat #{result_file}`
      
      `rm #{key_file}`
      `rm #{request_file}`
      `rm #{certificate_file}`
      `rm #{result_file}`
      `rm #{config_file}` if create_ca
      
      attempts += 1
      if attempts > 100
        request_data = 'OpenSSL error'
      end
    end
    
    request_data
  end
  
  def ensure_not_referenced_by_any_object
    if certificates.empty? && signs.empty?
      true
    else
      errors.add(:base, 'Referenced objects present')
      false
    end
  end
end








