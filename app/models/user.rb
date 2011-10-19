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
  
  def admin?
    admin
  end
  
  def blocked?
    block
  end
  
  private
  
  def prepare_values
    email.downcase!
    email.strip!
    first_name.strip!
    last_name.strip!
  end
end
