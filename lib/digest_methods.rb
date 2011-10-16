module DigestMethods
  
  def self.included(klass)
  end
  
  def generate_digest
    require 'digest/sha2'
    digest = Digest::SHA1.hexdigest(self.body)
    self.update_attribute(:sha, digest)
  end
  
  def digest
    self.sha
  end
  
end