require File.dirname(__FILE__) + '/../tahi_env'

class TahiEnv
  class EnvVar
    attr_reader :env_var

    def initialize(env_var)
      @env_var = env_var
    end

    def ==(other)
      other.is_a?(self.class) &&
        other.env_var == env_var
    end
  end
end
