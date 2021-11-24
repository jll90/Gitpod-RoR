module Validations
  module PhoneNumber
    def self.validate(phone_number)
      return false if phone_number.nil?
      correct_prefix = phone_number.starts_with? "569"
      slice = phone_number.slice(3, 8)
      return false if slice.nil?
      correct_prefix && slice.length == 8
    end
  end
end