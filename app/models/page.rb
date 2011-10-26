class Page < ActiveRecord::Base
  
  has_one :sign, as: :signable, dependent: :destroy
  mount_uploader :file, FileUploader
  
  attr_accessible :title, :body, :file
  
  validates :user_id, presence: true, numericality: { only_integer: true, minimum: 1 }
  
  before_validation :set_user_id
  after_validation :generate_digest
  
  def generate_digest
    require 'digest/sha2' 
    digest = Digest::SHA1.hexdigest(self.body)
    file_url = "#{Rails.root}/public#{file.url}"
    file_digest = Digest::SHA1.hexdigest(File.read(file_url)) unless file.url.blank?
    self.update_attribute(:sha, digest)
    self.update_attribute(:file_sha, file_digest) unless file.url.blank?
  end
  
  def digest
    Digest::SHA1.hexdigest("#{self.sha}|#{self.file_sha}")
  end
  
  
  private
  
  def set_user_id
    if self.user_id == 0 || self.user_id.blank?
      self.user_id = User.first.id
    end
  end
end
