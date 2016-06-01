require 'active_model'
require 'active_support/core_ext/string/strip'
require File.dirname(__FILE__) + '/tahi_env/dsl_methods'
require File.dirname(__FILE__) + '/tahi_env/env_var'
require File.dirname(__FILE__) + '/tahi_env/optional_env_var'
require File.dirname(__FILE__) + '/tahi_env/required_env_var'
require File.dirname(__FILE__) + '/tahi_env/boolean_validator'
require File.dirname(__FILE__) + '/tahi_env/presence_validator'

# TahiEnv is the class responsible for specifying which environment variables
# the application expects to interact with. It is so the application can
# validate it's environment during boot.
class TahiEnv
  extend DslMethods
  include ActiveModel::Validations

  class Error < ::StandardError ; end
  class InvalidEnvironment < Error ; end
  class MissingEnvVarRegistration < Error ; end

  def self.validate!
    instance.validate!
  end

  ########################################################################
  #                 ENV VAR REGISTRATION - THINGS TO KNOW
  ########################################################################
  # Every ENV var registration you see below will generate reader methods.
  #
  #     required :APP_NAME
  #
  # will provide:
  #
  #     TahiEnv.APP_NAME # returns the raw env variable
  #     TahiEnv.app_name # returns the coerced env variable value
  #
  # The second form above makes more sense when accesing booleans:
  #
  #     required :FOO_ENABLED, :boolean
  #
  # will provide:
  #
  #     TahiEnv.FOO_ENABLED  # returns the raw env variable
  #     TahiEnv.foo_enabled? # returns the coerced env variable value
  #
  # Note in the second reader method generated there is an appended '?'.

  validate :validate_at_least_one_form_of_auth

  # App
  required :APP_NAME
  required :ADMIN_EMAIL
  required :PASSWORD_AUTH_ENABLED, :boolean
  required :RAILS_ASSET_HOST, if: :staging_or_production?
  required :RAILS_ENV
  required :RAILS_SECRET_TOKEN
  required :DEFAULT_MAILER_URL
  required :FROM_EMAIL
  optional :FORCE_SSL, :boolean, default: true
  optional :MAX_ABSTRACT_LENGTH
  optional :PING_URL
  optional :PUSHER_SOCKET_URL
  optional :REPORTING_EMAIL

  # Amazon S3
  required :S3_URL
  required :S3_BUCKET
  required :AWS_ACCESS_KEY_ID
  required :AWS_SECRET_ACCESS_KEY
  required :AWS_REGION

  # Basic Auth
  optional :BASIC_AUTH_REQUIRED, :boolean, default: false
  required :BASIC_HTTP_USERNAME, if: :basic_auth_required?
  required :BASIC_HTTP_PASSWORD, if: :basic_auth_required?

  # Bugsnag
  optional :BUGSNAG_API_KEY
  optional :BUGSNAG_JAVASCRIPT_API_KEY

  # CAS
  required :CAS_ENABLED, :boolean
  required :CAS_SIGNUP_URL, if: :cas_enabled?
  required :CAS_SSL_VERIFY, :boolean, if: :cas_enabled?
  required :CAS_HOST, if: :cas_enabled?
  required :CAS_LOGIN_URL, if: :cas_enabled?
  required :CAS_LOGOUT_URL, if: :cas_enabled?
  required :CAS_PORT, if: :cas_enabled?
  required :CAS_SERVICE_VALIDATE_URL, if: :cas_enabled?
  required :CAS_SSL, :boolean, if: :cas_enabled?
  optional :CAS_CALLBACK_URL

  # EM / Editorial Manager
  optional :EM_DATABASE

  # Event Stream
  required :EVENT_STREAM_WS_HOST
  required :EVENT_STREAM_WS_PORT

  # FTP
  required :FTP_ENABLED, :boolean
  required :FTP_HOST, if: :ftp_enabled?
  required :FTP_USER, if: :ftp_enabled?
  required :FTP_PASSWORD, if: :ftp_enabled?
  required :FTP_PORT, if: :ftp_enabled?
  required :FTP_DIR, if: :ftp_enabled?

  # Hipchat
  optional :HIPCHAT_AUTH_TOKEN

  # Heroku
  optional :HEROKU_APP_NAME
  optional :HEROKU_PARENT_APP_NAME

  # iHat
  required :IHAT_URL
  optional :IHAT_CALLBACK_HOST
  optional :IHAT_CALLBACK_PORT

  # Mailsafe
  optional :MAILSAFE_REPLACEMENT_ADDRESS

  # NED
  required :NED_API_URL
  required :NED_CAS_APP_ID
  required :NED_CAS_APP_PASSWORD
  optional :NED_SSL_VERIFY, :boolean, default: true
  required :USE_NED_INSTITUTIONS, :boolean

  # Newrelic
  optional :NEWRELIC_KEY
  optional :NEWRELIC_APP_NAME

  # Orcid
  optional :ORCID_ENABLED, :boolean, default: false
  required :ORCID_API_HOST, if: :orcid_enabled?
  required :ORCID_SITE_HOST, if: :orcid_enabled?

  # Puma
  optional :PUMA_WORKERS
  optional :MAX_THREADS
  optional :PORT
  optional :RACK_ENV

  # Pusher / Slanger
  required :PUSHER_URL
  required :PUSHER_SSL_VERIFY, :boolean
  required :PUSHER_VERBOSE_LOGGING, :boolean

  # Salesforce
  optional :SALESFORCE_ENABLED, :boolean, default: true
  required :DATABASEDOTCOM_HOST, if: :salesforce_enabled?
  required :DATABASEDOTCOM_CLIENT_ID, if: :salesforce_enabled?
  required :DATABASEDOTCOM_CLIENT_SECRET, if: :salesforce_enabled?
  required :DATABASEDOTCOM_USERNAME, if: :salesforce_enabled?
  required :DATABASEDOTCOM_PASSWORD, if: :salesforce_enabled?

  # Segment IO
  optional :SEGMENT_IO_WRITE_KEY

  # Sendgrid
  required :SENDGRID_USERNAME
  required :SENDGRID_PASSWORD

  # Sidekiq
  optional :SIDEKIQ_CONCURRENCY

  def validate!
    unless valid?
      error_message = "Environment validation failed:\n\n"
      errors.full_messages.each do |error|
        error_message << "* #{error}\n"
      end
      error_message << "\n"
      fail InvalidEnvironment, error_message
    end
  end

  private

  def staging_or_production?
    %w(staging production).include? ENV['RAILS_ENV']
  end

  def validate_at_least_one_form_of_auth
    has_auth = cas_enabled? || orcid_enabled? || password_auth_enabled?
    unless has_auth
      errors.add \
        :base,
        'Expected at least one form of authentication to be enabled, but none were. Possible forms: CAS, ORCID, PASSWORD_AUTH'
    end
  end
end
