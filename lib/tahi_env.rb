require 'tahi_env/env_var'
require 'tahi_env/presence_validator'

class TahiEnv
  include ActiveModel::Validations

  class RequiredEnvVar < EnvVar ; end
  class OptionalEnvVar < EnvVar ; end

  def self.env_vars
    @env_vars = @env_vars || {}
  end

  def self.optional(env_var)
    env_vars[env_var.to_s] = OptionalEnvVar.new(env_var.to_s)
  end

  def self.required(env_var)
    validates env_var, presence: true
    env_vars[env_var.to_s] = RequiredEnvVar.new(env_var.to_s)
  end

  def self.validates(env_var, *args)
    define_method(env_var) do
      ENV["#{env_var}"]
    end
    super
  end

  required :APP_NAME
  required :ADMIN_EMAIL

  required :FTP_HOST
  required :FTP_USER
  required :FTP_PASSWORD
  required :FTP_PORT
  required :FTP_DIR

  required :S3_URL
  required :S3_BUCKET
  required :AWS_ACCESS_KEY_ID
  required :AWS_SECRET_ACCESS_KEY
  required :AWS_REGION

  optional :IHAT_CALLBACK_HOST
  optional :IHAT_CALLBACK_PORT
  optional :REPORTING_EMAIL
end
