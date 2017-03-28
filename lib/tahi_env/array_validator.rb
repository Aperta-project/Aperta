require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class ArrayValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value
        unless YAML::load(value).kind_of?(Array)
          message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a string that contains an array of strings, but was set to #{value.inspect}. Allowed array value is in the format \"['server1', 'server2' ,'server3']\"."
          record.errors.add :base, message
        end
      else
        message = options[:message] || "Environment Variable: #{attribute} was expected to be set to a string that contains an array of strings, but was not set. Allowed array value is in the format \"['server1', 'server2' ,'server3']\"."
        record.errors.add :base, message
      end
    end
  end
end
