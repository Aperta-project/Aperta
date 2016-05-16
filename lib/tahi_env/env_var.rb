require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    attr_reader :key
    attr_reader :type
    attr_reader :default_value

    def initialize(key, type = nil, default: nil)
      @key = key.to_s
      @type = type
      @default_value = default
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.key == key
    end

    def value
      if raw_value_from_env.nil?
        default_value
      elsif boolean?
        converted_boolean_value
      else
        raw_value_from_env
      end
    end

    def raw_value_from_env
      ENV[@key]
    end

    def boolean?
      @type == :boolean
    end

    def converted_boolean_value
      ['true', '1'].include?(raw_value_from_env) ? true : false
    end
  end
end
