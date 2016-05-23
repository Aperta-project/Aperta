require 'spec_helper'
require 'climate_control'
require File.dirname(__FILE__) + '/../../lib/tahi_env'
require File.dirname(__FILE__) + '/../support/shared_examples/tahi_env_shared_examples'

describe TahiEnv do
  subject(:env) { TahiEnv.new.tap(&:validate) }

  let(:valid_env) do
    {
      APP_NAME: 'Aperta',
      ADMIN_EMAIL: 'aperta@example.com',
      BUGSNAG_API_KEY: 'rails_api_key',
      CAS_ENABLED: 'false',
      DATABASEDOTCOM_CLIENT_ID: 'abc9876',
      DATABASEDOTCOM_CLIENT_SECRET: '765abfg',
      DATABASEDOTCOM_HOST: 'salesforce.tahi-project.org',
      DATABASEDOTCOM_PASSWORD: 'password',
      DATABASEDOTCOM_USERNAME: 'username',
      DEFAULT_MAILER_URL: 'http://mailer.tahi-project.org',
      PUSHER_SSL_VERIFY: 'true',
      FROM_EMAIL: 'no-reply@tahi-project.org',
      FTP_HOST: 'ftp://foo.bar',
      FTP_USER: 'the-oracle',
      FTP_PASSWORD: 'tiny-green-characters',
      FTP_PORT: '21',
      FTP_DIR: 'where/the/wild/things/are',
      IHAT_URL: 'http://ihat.tahi-project.com',
      NED_API_URL: 'http://ned.example.com',
      NED_CAS_APP_ID: 'ned123',
      NED_CAS_APP_PASSWORD: 'password',
      USE_NED_INSTITUTIONS: 'false',
      S3_URL: 'http://tahi-test.amazonaws.com',
      S3_BUCKET: 'tahi',
      AWS_ACCESS_KEY_ID: 'DNCDCC55F',
      AWS_SECRET_ACCESS_KEY: '98Abc754',
      AWS_REGION: 'us-west',
      EVENT_STREAM_WS_HOST: 'slanger-staging.tahi-project.org',
      EVENT_STREAM_WS_PORT: '8080',
      ORCID_ENABLED: 'true',
      ORCID_API_HOST: 'api.sandbox.orcid.org',
      ORCID_SITE_HOST: 'sandbox.orcid.com',
      PASSWORD_AUTH_ENABLED: 'true',
      PUSHER_URL: 'http://pusher.tahi-project.org',
      PUSHER_VERBOSE_LOGGING: 'false',
      RAILS_ENV: 'test',
      RAILS_SECRET_TOKEN: 'secret-token',
      SENDGRID_USERNAME: 'username',
      SENDGRID_PASSWORD: 'password'
    }
  end

  # App
  include_examples 'required env var', var: 'APP_NAME'
  include_examples 'required env var', var: 'ADMIN_EMAIL'
  include_examples 'required env var', var: 'PASSWORD_AUTH_ENABLED'
  include_examples 'required env var', var: 'RAILS_ENV'
  include_examples 'required env var', var: 'RAILS_SECRET_TOKEN'
  include_examples 'optional env var', var: 'RAILS_ASSET_HOST'
  include_examples 'required env var', var: 'DEFAULT_MAILER_URL'
  include_examples 'optional boolean env var', var: 'FORCE_SSL', default_value: true
  include_examples 'required env var', var: 'FROM_EMAIL'
  include_examples 'optional env var', var: 'MAX_ABSTRACT_LENGTH'
  include_examples 'optional env var', var: 'PING_URL'
  include_examples 'optional env var', var: 'PUSHER_SOCKET_URL'
  include_examples 'optional env var', var: 'REPORTING_EMAIL'

  # Amazon S3
  include_examples 'required env var', var: 'S3_URL'
  include_examples 'required env var', var: 'S3_BUCKET'
  include_examples 'required env var', var: 'AWS_ACCESS_KEY_ID'
  include_examples 'required env var', var: 'AWS_SECRET_ACCESS_KEY'
  include_examples 'required env var', var: 'AWS_REGION'

  # Basic Auth
  include_examples 'optional boolean env var', var: 'BASIC_AUTH_REQUIRED', default_value: false
  include_examples 'dependent required env var', var: 'BASIC_HTTP_USERNAME', dependent_key: 'BASIC_AUTH_REQUIRED'
  include_examples 'dependent required env var', var: 'BASIC_HTTP_PASSWORD', dependent_key: 'BASIC_AUTH_REQUIRED'

  # Bugsnag
  include_examples 'required env var', var: 'BUGSNAG_API_KEY'
  include_examples 'optional env var', var: 'BUGSNAG_JAVASCRIPT_API_KEY'

  # CAS
  include_examples 'required boolean env var', var: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_SIGNUP_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required boolean env var', var: 'CAS_SSL_VERIFY', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_HOST', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_LOGIN_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_LOGOUT_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_PORT', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_SERVICE_VALIDATE_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required boolean env var', var: 'CAS_SSL', dependent_key: 'CAS_ENABLED'
  include_examples 'optional env var', var: 'CAS_CALLBACK_URL'

  # EM / Editorial Manager
  include_examples 'optional env var', var: 'EM_DATABASE'

  # Event Stream
  include_examples 'required env var', var: 'EVENT_STREAM_WS_HOST'
  include_examples 'required env var', var: 'EVENT_STREAM_WS_PORT'

  # FTP
  include_examples 'required env var', var: 'FTP_DIR'
  include_examples 'required env var', var: 'FTP_HOST'
  include_examples 'required env var', var: 'FTP_PASSWORD'
  include_examples 'required env var', var: 'FTP_PORT'
  include_examples 'required env var', var: 'FTP_USER'

  # Heroku
  include_examples 'optional env var', var: 'HEROKU_APP_NAME'
  include_examples 'optional env var', var: 'HEROKU_PARENT_APP_NAME'

  # Hipchat
  include_examples 'optional env var', var: 'HIPCHAT_AUTH_TOKEN'

  # iHat
  include_examples 'required env var', var: 'IHAT_URL'
  include_examples 'optional env var', var: 'IHAT_CALLBACK_HOST'
  include_examples 'optional env var', var: 'IHAT_CALLBACK_PORT'

  # Mailsafe
  include_examples 'optional env var', var: 'MAILSAFE_REPLACEMENT_ADDRESS'

  # NED
  include_examples 'required env var', var: 'NED_API_URL'
  include_examples 'required env var', var: 'NED_CAS_APP_ID'
  include_examples 'required env var', var: 'NED_CAS_APP_PASSWORD'
  include_examples 'optional boolean env var', var: 'NED_SSL_VERIFY', default_value: true
  include_examples 'required boolean env var', var: 'USE_NED_INSTITUTIONS'

  # Newrelic
  include_examples 'optional env var', var: 'NEWRELIC_KEY'
  include_examples 'optional env var', var: 'NEWRELIC_APP_NAME'

  # Orcid
  include_examples 'optional boolean env var', var: 'ORCID_ENABLED', default_value: false
  include_examples 'dependent required env var', var: 'ORCID_API_HOST', dependent_key: 'ORCID_ENABLED'
  include_examples 'dependent required env var', var: 'ORCID_SITE_HOST', dependent_key: 'ORCID_ENABLED'

  # Puma
  include_examples 'optional env var', var: 'PUMA_WORKERS'
  include_examples 'optional env var', var: 'MAX_THREADS'
  include_examples 'optional env var', var: 'PORT'
  include_examples 'optional env var', var: 'RACK_ENV'

  # Pusher / Slanger
  include_examples 'required env var', var: 'PUSHER_URL'
  include_examples 'required boolean env var', var: 'PUSHER_SSL_VERIFY'
  include_examples 'required boolean env var', var: 'PUSHER_VERBOSE_LOGGING'

  # Salesforce
  include_examples 'optional boolean env var', var: 'SALESFORCE_ENABLED', default_value: true
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_HOST', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_ID', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_SECRET', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_USERNAME', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_PASSWORD', dependent_key: 'SALESFORCE_ENABLED'

  # Segment IO
  include_examples 'optional env var', var: 'SEGMENT_IO_WRITE_KEY'

  # Sendgrid
  include_examples 'required env var', var: 'SENDGRID_USERNAME'
  include_examples 'required env var', var: 'SENDGRID_PASSWORD'

  # Sidekiq
  include_examples 'optional env var', var: 'SIDEKIQ_CONCURRENCY'

  describe '#validate!' do
    it 'does not raise an error when the environment is valid' do
      expect do
        ClimateControl.modify valid_env do
          expect { env.validate! }.to_not raise_error
        end
      end
    end

    it 'raises an error when the environment is not valid' do
      invalid_env = valid_env.merge(:APP_NAME => nil, :ADMIN_EMAIL => nil)
      ClimateControl.modify invalid_env do
        expect do
          env.validate!
        end.to raise_error(TahiEnv::InvalidEnvironment) do |error|
          expect(error.message).to include(
            'Environment Variable: APP_NAME was expected'
          )
          expect(error.message).to include(
            'Environment Variable: ADMIN_EMAIL was expected'
          )
        end
      end
    end
  end
end
