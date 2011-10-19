class IssuingByCaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if  record.certificate &&
        record.certificate_id > 0 &&
        !Certificate.find(record.certificate_id).ca?
      record.errors[attribute] << "is wrong"
    end
  end
end