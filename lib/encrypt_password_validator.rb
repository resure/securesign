class EncryptPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if  !record.body.blank? &&
        !record.password.blank? &&
        !(BCrypt::Password.new(record.old_password_digest) == record.old_password)
      record.errors[attribute] << "is wrong"
    end
  end
end