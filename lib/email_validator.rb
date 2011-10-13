require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      mail   = Mail::Address.new(value)
      result = mail.domain && mail.address == value
      top    = mail.__send__(:tree)
      result &&= (top.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e
      result = false
    end
    record.errors[attribute] << (options[:message] || I18n.t(:is_invalid)) unless result
  end
end