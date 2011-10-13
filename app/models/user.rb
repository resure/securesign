# encoding: utf-8

class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name
  
  validates :email, length: { within: 5..254 },
                    uniqueness: { case_sensitive: false },
                    email: true
  validates :first_name, :last_name,  presence: true, 
                                      length: { within: 3..50 },
                                      format: /^[\wа-яА-Я\d\s\-]+$/
  validates :password, confirmation: true, presence: { on: :create }
  
  before_validation :prepare_values
  
  
  private
  
  def prepare_values
    email.downcase!
    email.strip!
    first_name.strip!
    last_name.strip!
  end
end
