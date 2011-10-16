class Key < ActiveRecord::Base
  include DigestMethods  
  has_secure_password
  
  belongs_to :user
  
  attr_accessible :title, :password, :password_confirmation, :old_password
  attr_accessor :old_password, :old_password_digest
  
  before_validation :prepare_values, :set_user_id
  
  validates_associated :user
  
  validates :title, length: { within: 3..254 }
  validates :user_id, numericality: { only_integer: true, minimum: 1 }
  validates :password,  :length => { :within => 6..254 },
                        :confirmation => true,
                        :if => :password_digest_changed?
  validates :old_password,  :encrypt_password => true
  
  
  def password=(unencrypted_password)
    @old_password_digest = self.password_digest
    @password = unencrypted_password
    unless unencrypted_password.blank?
      self.password_digest = BCrypt::Password.create(unencrypted_password)
    end
  end
  
  def generate_key(key_password = self.password)
    key_data, public_key_data = openssl_generate_key(key_password)
    self.update_attribute(:body, key_data)
    self.update_attribute(:public_body, public_key_data)
    
    generate_digest
    true
  end
  
  def update_password(old_password, new_password = self.password)
    key_data = openssl_update_key_password(old_password, new_password)
    self.update_attribute(:body, key_data)
    
    generate_digest
    true
  end
  
  
  private
  
  def openssl_generate_key(key_password)
    key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    public_key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    
    attempts = 0
    
    require "pty"
    require "expect"
    
    key_data = ''
    while key_data.blank?
      PTY.spawn("openssl genrsa -aes256 2048 > #{key_file}") do |reader, writer|
        reader.expect(/Enter pass/)
        writer.puts("#{key_password}\n")
        reader.expect(/Verifying/)
        writer.puts("#{key_password}\n")
      end
      
      key_data = `cat #{key_file}`
      
      attempts += 1
      if attempts > 100
        key_data = 'OpenSSL error'
      end
    end
    
    attempts = 0
    public_key_data = ''
    
    while public_key_data.blank? do
      PTY.spawn("openssl rsa -in #{key_file} -pubout > #{public_key_file}") do |reader, writer|
        reader.expect(/Enter pass/)
        writer.puts("#{key_password}\n")
      end
      
      public_key_data = `cat #{public_key_file}`
      
      attempts += 1
      if attempts > 100
        public_key_data = 'OpenSSL error'
      end
    end
    
    `rm #{key_file}`
    `rm #{public_key_file}`
    
    [key_data, public_key_data]
  end
  
  def openssl_update_key_password(old_password, new_password)
    key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    new_key_file = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    
    attempts = 0
    new_key_data = ''
    
    require "pty"
    require "expect"
    while new_key_data.blank? do
      `echo '#{self.body}' > #{key_file}`
      
      PTY.spawn("openssl rsa -aes256 -in #{key_file} -out #{new_key_file}") do |reader, writer| 
        reader.expect(/Enter/)
        writer.puts("#{old_password}\n")

        reader.expect(/writing/)
        writer.puts("#{new_password}\n")

        reader.expect(/Verifying/)
        writer.puts("#{new_password}\n")
      end
      
      new_key_data = `cat #{new_key_file}`
      
      attempts += 1
      if attempts > 100
        new_key_data = 'OpenSSL error'
      end
    end
    
    `rm #{key_file}`
    `rm #{new_key_file}`
    
    new_key_data
  end
  
  def prepare_values
    title.strip!
  end
  
  def set_user_id
    self.user_id ||= User.first.id
  end
end
