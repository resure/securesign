class Sign < ActiveRecord::Base
  include DigestMethods
  
  belongs_to :signable, polymorphic: true
  belongs_to :key
  belongs_to :certificate
  
  def sign(key_password)
    if !key.authenticate(key_password)
      errors.add(:base, 'Wrong key password')
      false
    elsif certificate.request_status == 2
      errors.add(:base, 'Certificate was not signed')
      false
    else
      sign_data = openssl_sign(key_password)
      update_attribute(:body, sign_data)
      generate_digest
      true
    end
  end
  
  def verify_sign
    verifying_result = openssl_verify_sign
  end
  
  
  private
  
  def openssl_sign(key_password)
    key_file          = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    digest_file       = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    sign_file         = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    
    query = "openssl rsautl"
    query += " -sign"
    query += " -in #{digest_file}"
    query += " -inkey #{key_file}"
    query += " -out #{sign_file}"
    
    check_digest = "#{self.certificate.digest}|#{self.signable.digest}"
    
    attempts = 0
    sign_data = ''

    require "pty"
    require "expect"
    require 'base64'
    require 'digest/sha2'
    
    while sign_data.blank? do
      `echo "#{self.key.body}" > #{key_file}`
      `echo "#{check_digest}" > #{digest_file}`
      
      PTY.spawn(query) do |reader, writer|
        reader.expect(/Enter pass/)
        writer.puts("#{key_password}\n")
      end

      sign_data = Base64.encode64(`cat #{sign_file}`)
      
      attempts += 1
      if attempts > 100
        sign_data = 'OpenSSL error'
      end
      
      `rm #{key_file}`
      `rm #{digest_file}`
      `rm #{sign_file}`
    end

    sign_data
  end
  
  def openssl_verify_sign
    public_key_file       = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    sign_file             = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    tmp_file              = Rails.root + 'tmp/' + SecureRandom.urlsafe_base64
    
    check_digest = "#{self.certificate.digest}|#{self.signable.digest}"
    
    query = "openssl base64 -base64 -d -in #{sign_file} > #{tmp_file}"
    query += " && openssl rsautl -in #{tmp_file} -inkey #{public_key_file} -pubin -verify"
    
    verify_sign_data = ''
    attempts = 0
    
    require 'base64'
    require 'digest/sha2'
    
    while verify_sign_data.blank?
      `echo "#{self.key.public_body}" > #{public_key_file}`
      `echo "#{self.body}" > #{sign_file}`
      
      verify_sign_data = `#{query}`
      
      attempts += 1
      if attempts > 100
        verify_sign_data = 'OpenSSL error'
      end
    end
    
    verify_sign_data.strip!
    
    [check_digest, verify_sign_data]
  end
end










