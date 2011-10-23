# encoding: utf-8

class User < ActiveRecord::Base
  has_secure_password
  
  has_many :keys
  has_many :certificates
  
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name
  
  validates :email, uniqueness: { case_sensitive: false },
                    email: true
  validates :first_name, :last_name, format: /^[\wа-яА-Я\d\s\-]+$/
  validates :password,  length: { :within => 6..254, :on => :create },
                        if: :password_digest_changed?
  
  before_validation :prepare_values
  
  before_destroy :ensure_not_referenced_by_any_object
  
  def admin?
    admin
  end
  
  def blocked?
    block
  end
  
  
  private
  
  def ensure_not_referenced_by_any_object
    if !keys.empty?
      errors.add(:base, 'Referenced keys present')
      false
    elsif !certificates.empty?
      errors.add(:base, 'Referenced certificates present')
    else
      true
    end
  end
  
  def prepare_values
    email.downcase!
    email.strip!
    first_name.strip!
    last_name.strip!
  end
end
