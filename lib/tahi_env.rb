require 'tahi_env/env_var'
require 'tahi_env/presence_validator'

class TahiEnv
  include ActiveModel::Validations

  class RequiredEnvVar < EnvVar ; end
  class OptionalEnvVar < EnvVar ; end

  def self.env_vars
    @env_vars = @env_vars || {}
  end

  def self.instance
    @instance ||= TahiEnv.new
  end

  def self.optional(env_var, type = nil, default: nil)
    optional_env_var = OptionalEnvVar.new(
      env_var,
      type,
      default: default
    )
    register_env_var(optional_env_var)
  end

  def self.required(env_var, type = nil, **kwargs)
    default_value = kwargs[:default]
    if_method = kwargs[:if]

    required_env_var = RequiredEnvVar.new(
      env_var,
      type,
      default: default_value
    )
    register_env_var(required_env_var)

    validation_args = { presence: true }
    validation_args[:if] = if_method if if_method
    validates env_var, **validation_args
  end

  def self.register_env_var(env_var)
    env_vars[env_var.env_var] = env_var

    # TahiEnv#APP_NAME
    reader_method = env_var.env_var
    define_method(reader_method) do
      env_var.raw_value_from_env
    end

    # TahiEnv#app_name
    # TahiEnv#orcid_enabled?
    reader_method = "#{env_var.env_var.downcase}"
    reader_method << "?" if env_var.boolean?
    define_method(reader_method) do
      env_var.value
    end
  end

  def self.method_missing(method, *args, &blk)
    if instance.respond_to?(method)
      instance.send(method, *args, &blk)
    else
      super
    end
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

  optional :NEWRELIC_KEY
  optional :NEWRELIC_APP_NAME

  optional :ORCID_ENABLED, :boolean, default: false
  required :ORCID_API_HOST, if: :orcid_enabled?
  required :ORCID_SITE_HOST, if: :orcid_enabled?

  optional :PUMA_WORKERS
  optional :MAX_THREADS
  optional :PORT
  optional :RACK_ENV

  optional :SIDEKIQ_CONCURRENCY
end
