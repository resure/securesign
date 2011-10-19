class KeyPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.key_id.blank? || !Key.find_by_id(record.key_id) || !Key.find_by_id(record.key_id).authenticate(value)
      unless record.key_password.blank?
        record.errors[attribute] << "is wrong"
      end
    end
  end
end