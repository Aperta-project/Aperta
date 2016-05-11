require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    attr_reader :env_var
    attr_reader :type
    attr_reader :default_value

    def initialize(env_var, type = nil, default_value = nil)
      @env_var = env_var
      @type = type
      @default_value = default_value
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.env_var == env_var
    end

    def value
      boolean? ? converted_boolean_value : env_setting_value
    end

    def env_setting_value
      ENV[@env_var]
    end

    def boolean?
      @type == :boolean
    end

    def converted_boolean_value
      ['true', '1'].include?(env_setting_value) ? true : false
    end
  end
end
