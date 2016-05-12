require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class BooleanValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        if !['true', '1', 'false', '0'].include?(value)
          message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a boolean value, but was set to #{value.inspect}. Allowed boolean values are true (true, 1), or false (false, 0)."
          record.errors.add :base, message
        end
      else
        message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a boolean, but was not set. Allowed boolean values are true (true, 1), or false (false, 0)."
        record.errors.add :base, message
      end
    end
  end
end
