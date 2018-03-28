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
      APEX_FTP_ENABLED: 'false',
      BILLING_FTP_ENABLED: 'false',
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
      FTP_ENABLED: 'false',
      FTP_URL: 'ftp://the-oracle:tiny-green-characters@foo.bar:21/where/the/wild/things/are',
      IHAT_URL: 'http://ihat.tahi-project.com',
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
      ORCID_LOGIN_ENABLED: 'true',
      ORCID_CONNECT_ENABLED: 'true',
      ORCID_API_HOST: 'api.sandbox.orcid.org',
      ORCID_SITE_HOST: 'sandbox.orcid.com',
      ORCID_SECRET: 'orcidsecret',
      ORCID_KEY: 'orcidkey',
      ORCID_API_VERSION: '1.2',
      PASSWORD_AUTH_ENABLED: 'true',
      PUSHER_URL: 'http://pusher.tahi-project.org',
      PUSHER_VERBOSE_LOGGING: 'false',
      RAILS_ENV: 'test',
      RAILS_SECRET_TOKEN: 'secret-token',
      REDIS_SENTINEL_ENABLED: 'true',
      REDIS_SENTINELS: "sentinel://localhost:6379 sentinel://localhost:6379",
      SENDGRID_USERNAME: 'username',
      SENDGRID_PASSWORD: 'password'
    }
  end

  # App
  it_behaves_like 'required env var', var: 'APP_NAME'
  it_behaves_like 'required env var', var: 'ADMIN_EMAIL'
  it_behaves_like 'optional boolean env var', var: 'PASSWORD_AUTH_ENABLED', default_value: true
  it_behaves_like 'required env var', var: 'RAILS_ENV'
  it_behaves_like 'dependent required env var', var: 'RAILS_ASSET_HOST', dependent_key: 'RAILS_ENV', dependent_values: %w(staging production)
  it_behaves_like 'required env var', var: 'RAILS_SECRET_TOKEN'
  it_behaves_like 'required env var', var: 'DEFAULT_MAILER_URL'
  it_behaves_like 'optional boolean env var', var: 'FORCE_SSL', default_value: true
  it_behaves_like 'required env var', var: 'FROM_EMAIL'
  it_behaves_like 'optional env var', var: 'MAX_ABSTRACT_LENGTH'
  it_behaves_like 'optional env var', var: 'PING_URL'
  it_behaves_like 'optional env var', var: 'PUSHER_SOCKET_URL'
  it_behaves_like 'optional env var', var: 'REPORTING_EMAIL'

  # Apex FTP
  it_behaves_like 'optional boolean env var', var: 'APEX_FTP_ENABLED', default_value: false
  include_examples 'dependent required env var', var: 'APEX_FTP_URL', dependent_key: 'APEX_FTP_ENABLED'

  # Amazon S3
  it_behaves_like 'required env var', var: 'S3_URL'
  it_behaves_like 'required env var', var: 'S3_BUCKET'
  it_behaves_like 'required env var', var: 'AWS_ACCESS_KEY_ID'
  it_behaves_like 'required env var', var: 'AWS_SECRET_ACCESS_KEY'
  it_behaves_like 'required env var', var: 'AWS_REGION'

  # Basic Auth
  it_behaves_like 'optional boolean env var', var: 'BASIC_AUTH_REQUIRED', default_value: false
  it_behaves_like 'dependent required env var', var: 'BASIC_HTTP_USERNAME', dependent_key: 'BASIC_AUTH_REQUIRED'
  it_behaves_like 'dependent required env var', var: 'BASIC_HTTP_PASSWORD', dependent_key: 'BASIC_AUTH_REQUIRED'

  # Billing FTP
  it_behaves_like 'optional boolean env var', var: 'BILLING_FTP_ENABLED', default_value: false
  include_examples 'dependent required env var', var: 'BILLING_FTP_URL', dependent_key: 'BILLING_FTP_ENABLED'

  # Bugsnag
  it_behaves_like 'optional env var', var: 'BUGSNAG_API_KEY'
  it_behaves_like 'optional env var', var: 'BUGSNAG_JAVASCRIPT_API_KEY'

  # CAS
  it_behaves_like 'optional boolean env var', var: 'CAS_ENABLED', default_value: false
  it_behaves_like 'dependent required env var', var: 'CAS_SIGNUP_URL', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required boolean env var', var: 'CAS_SSL_VERIFY', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required env var', var: 'CAS_HOST', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required env var', var: 'CAS_LOGIN_URL', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required env var', var: 'CAS_LOGOUT_URL', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required env var', var: 'CAS_PORT', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required env var', var: 'CAS_SERVICE_VALIDATE_URL', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'dependent required boolean env var', var: 'CAS_SSL', dependent_key: 'CAS_ENABLED'
  it_behaves_like 'optional env var', var: 'CAS_CALLBACK_URL'

  # Event Stream
  it_behaves_like 'required env var', var: 'EVENT_STREAM_WS_HOST'
  it_behaves_like 'required env var', var: 'EVENT_STREAM_WS_PORT'

  # Heroku
  it_behaves_like 'optional env var', var: 'HEROKU_APP_NAME'
  it_behaves_like 'optional env var', var: 'HEROKU_PARENT_APP_NAME'

  # iHat
  it_behaves_like 'required env var', var: 'IHAT_URL'
  it_behaves_like 'optional env var', var: 'IHAT_CALLBACK_HOST'
  it_behaves_like 'optional env var', var: 'IHAT_CALLBACK_PORT'

  # Mailsafe
  it_behaves_like 'optional env var', var: 'MAILSAFE_REPLACEMENT_ADDRESS'

  # NED
  it_behaves_like 'dependent required env var', var: 'NED_API_URL', dependent_key: 'RAILS_ENV', dependent_values: %w(staging production)
  it_behaves_like 'required env var', var: 'NED_CAS_APP_ID'
  it_behaves_like 'required env var', var: 'NED_CAS_APP_PASSWORD'
  it_behaves_like 'optional boolean env var', var: 'NED_SSL_VERIFY', default_value: true
  it_behaves_like 'optional boolean env var', var: 'USE_NED_INSTITUTIONS', default_value: false

  # Newrelic
  it_behaves_like 'optional env var', var: 'NEWRELIC_KEY'
  it_behaves_like 'optional env var', var: 'NEWRELIC_APP_NAME'

  # Orcid
  it_behaves_like 'optional boolean env var', var: 'ORCID_LOGIN_ENABLED', default_value: false
  it_behaves_like 'optional boolean env var', var: 'ORCID_CONNECT_ENABLED', default_value: false
  it_behaves_like 'dependent required env var', var: 'ORCID_API_HOST', dependent_key: 'ORCID_CONNECT_ENABLED'
  it_behaves_like 'dependent required env var', var: 'ORCID_API_VERSION', dependent_key: 'ORCID_CONNECT_ENABLED'
  it_behaves_like 'dependent required env var', var: 'ORCID_SITE_HOST', dependent_key: 'ORCID_CONNECT_ENABLED'
  it_behaves_like 'dependent required env var', var: 'ORCID_SECRET', dependent_key: 'ORCID_CONNECT_ENABLED'
  it_behaves_like 'dependent required env var', var: 'ORCID_KEY', dependent_key: 'ORCID_CONNECT_ENABLED'

  # Puma
  it_behaves_like 'optional env var', var: 'PUMA_WORKERS'
  it_behaves_like 'optional env var', var: 'MAX_THREADS'
  it_behaves_like 'optional env var', var: 'PORT'
  it_behaves_like 'optional env var', var: 'RACK_ENV'

  # Redis Sentinel
  it_behaves_like 'dependent required array env var', var: 'REDIS_SENTINELS', dependent_key: 'REDIS_SENTINEL_ENABLED'

  # RouterApi
  it_behaves_like 'optional env var', var: 'ROUTER_URL'

  # Pusher / Slanger
  it_behaves_like 'required env var', var: 'PUSHER_URL'
  it_behaves_like 'optional boolean env var', var: 'PUSHER_SSL_VERIFY', default_value: true
  it_behaves_like 'optional boolean env var', var: 'PUSHER_VERBOSE_LOGGING', default_value: false

  # Salesforce
  it_behaves_like 'optional boolean env var', var: 'SALESFORCE_ENABLED', default_value: false
  it_behaves_like 'dependent required env var', var: 'DATABASEDOTCOM_HOST', dependent_key: 'SALESFORCE_ENABLED'
  it_behaves_like 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_ID', dependent_key: 'SALESFORCE_ENABLED'
  it_behaves_like 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_SECRET', dependent_key: 'SALESFORCE_ENABLED'
  it_behaves_like 'dependent required env var', var: 'DATABASEDOTCOM_USERNAME', dependent_key: 'SALESFORCE_ENABLED'
  it_behaves_like 'dependent required env var', var: 'DATABASEDOTCOM_PASSWORD', dependent_key: 'SALESFORCE_ENABLED'

  # Sendgrid
  it_behaves_like 'required env var', var: 'SENDGRID_USERNAME'
  it_behaves_like 'required env var', var: 'SENDGRID_PASSWORD'

  describe 'when no authentication is enabled' do
    it 'is not valid' do
      ClimateControl.modify CAS_ENABLED: "false", ORCID_LOGIN_ENABLED: "false", PASSWORD_AUTH_ENABLED: "false" do
        expect(env.errors.full_messages).to include \
          "Expected at least one form of authentication to be enabled, but none were. Possible forms: CAS, ORCID, PASSWORD_AUTH"
      end
    end
  end

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
