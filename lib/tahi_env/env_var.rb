require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    def self.type=(type)
      @type = type
    end

    def self.type
      @type
    end

    attr_reader :key, :type, :default_value, :additional_details

    def initialize(key, type = nil, default: nil, additional_details: nil)
      @key = key.to_s
      @type = type
      @default_value = default
      @additional_details = additional_details
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

    def to_s
      msg = "Environment Variable: #{key} (#{type}"
      msg << " #{additional_details}" if additional_details
      msg << ")"
    end

    def type
      self.class.type
    end

    private

    def converted_boolean_value
      ['true', '1'].include?(raw_value_from_env) ? true : false
    end
  end
end
