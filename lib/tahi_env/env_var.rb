require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    attr_reader :env_var
    attr_reader :type
    attr_reader :default_value

    def initialize(env_var, type = nil, default: nil)
      @env_var = env_var.to_s
      @type = type
      @default_value = default
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.env_var == env_var
    end

    def value
      boolean? ? converted_boolean_value : raw_value_from_env
    end

    def raw_value_from_env
      ENV[@env_var]
    end

    def boolean?
      @type == :boolean
    end

    def converted_boolean_value
      ['true', '1'].include?(raw_value_from_env) ? true : false
    end
  end
end
