class ConfigException < StandardError; end

# Helper class for configuration.
class ConfigHelper
  # Return false if env variable is set to "false" or unset.
  # Return true if env variable is set to "true" or "1"
  # fail otherwise.
  def self.read_boolean_env(name)
    val = ENV.fetch(name, 'false')
    if val.downcase == 'true' || val == '1'
      true
    elsif val.downcase == 'false'
      false
    else
      fail ConfigException, <<EOS
Please correct the value of the environment variable #{name}. Valid values are \
`true` or `false`.
EOS
    end
  end
end
