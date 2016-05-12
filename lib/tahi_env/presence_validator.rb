require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class PresenceValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        if value.empty?
          message = options[:message] || "Environment Variable: #{attribute} was expected to have a value, but was set to nothing."
          record.errors.add :base, message
        end
      else
        message = options[:message] || "Environment Variable: #{attribute} was expected to be set, but was not."
        record.errors.add :base, message
      end
    end
  end
end
