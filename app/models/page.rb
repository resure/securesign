class Page < ActiveRecord::Base
  include DigestMethods
  
  # has_one :sign, as: :signable, dependence: :destroy
  
  attr_accessible :title, :body
  
  validates :user_id, presence: true, numericality: { only_integer: true, minimum: 1 }
  
  before_validation :set_user_id
  after_validation :generate_digest
  
  private
  
  def set_user_id
    if self.user_id == 0 || self.user_id.blank?
      self.user_id = User.first.id
    end
  end
end
