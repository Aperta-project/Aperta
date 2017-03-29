require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class ArrayValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value.present?
        unless value.split(' ').kind_of?(Array)
          message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a string that contained a list of items, but was set to #{value.inspect}. Allowed values are in the format \"server1, server2 ,server3\"."
          record.errors.add :base, message
        end
      else
        message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a string that contained a list of items, but was not set. Allowed values are in the format \"server1, server2 ,server3\"."
        record.errors.add :base, message
      end
    end
  end
end
