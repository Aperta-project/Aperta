require File.dirname(__FILE__) + '/env_var'

class TahiEnv
  class OptionalEnvVar < EnvVar
    def to_s
      msg = "Environment Variable: #{key} (optional"
      msg << " #{additional_details}" if additional_details
      msg << ")"
      msg
    end
  end
end
