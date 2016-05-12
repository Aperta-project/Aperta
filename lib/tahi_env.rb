require 'tahi_env/env_var'
require 'tahi_env/presence_validator'

class TahiEnv
  include ActiveModel::Validations

  class RequiredEnvVar < EnvVar ; end
  class OptionalEnvVar < EnvVar ; end

  def self.env_vars
    @env_vars = @env_vars || {}
  end

  def self.optional(env_var, type = nil, default: nil)
    env_vars[env_var.to_s] = OptionalEnvVar.new(
      env_var.to_s,
      type,
      default: default
    )
  end

  def self.required(env_var, type = nil, **kwargs)
    default_value = kwargs[:default]
    if_method = kwargs[:if]

    validation_args = { presence: true }

    if if_method
      validation_args[:if] = -> { self.class.send(if_method.to_s) }
    end

    validates env_var, **validation_args

    env_vars[env_var.to_s] = RequiredEnvVar.new(
      env_var.to_s,
      type,
      default: default_value
    )
  end

  def self.validates(env_var, *args)
    define_method(env_var) do
      ENV["#{env_var}"]
    end
    super
  end

  def self.method_missing(method, *args, &block)
    env_var_name = "#{method.to_s.upcase.gsub(/\W/, '')}"
    env_var = env_vars[env_var_name]
    env_var.present? ? env_var.value : super
  end

  required :APP_NAME
  required :ADMIN_EMAIL
  required :RAILS_ENV

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

  required :BUGSNAG_API_KEY
  optional :BUGSNAG_JAVASCRIPT_API_KEY

  required :EVENT_STREAM_WS_HOST
  required :EVENT_STREAM_WS_PORT

  optional :IHAT_CALLBACK_HOST
  optional :IHAT_CALLBACK_PORT
  required :IHAT_URL

  optional :HIPCHAT_AUTH_TOKEN
  optional :MAX_ABSTRACT_LENGTH
  optional :PING_URL
  optional :PUSHER_SOCKET_URL
  optional :REPORTING_EMAIL
  optional :SEGMENT_IO_WRITE_KEY

  optional :CAS_ENABLED, :boolean, default: false
  optional :CAS_SIGNUP_URL

  optional :ORCID_ENABLED, :boolean, default: false
  required :ORCID_API_HOST, if: :orcid_enabled?
end
