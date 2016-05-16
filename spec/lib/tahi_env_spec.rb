require 'spec_helper'
require 'climate_control'
require 'active_model'
require File.dirname(__FILE__) + '/../../lib/tahi_env'

describe TahiEnv do
  subject(:env) { TahiEnv.new.tap(&:validate) }

  shared_examples_for 'required env var' do |var:|
    describe "Required env var: #{var}" do
      it 'is required to be set' do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set, but was not.")
        end
      end

      it 'is required to have a value' do
        ClimateControl.modify valid_env.merge("#{var}": '') do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to have a value, but was set to nothing.")
        end
      end

      it 'shows up in the list of known about env vars' do
        expect(TahiEnv.env_vars[var.to_s]).to eq(
          TahiEnv::RequiredEnvVar.new(var)
        )
      end
    end

    reader_method_name = "#{var.downcase}"
    describe "TahiEnv.#{reader_method_name}" do
      it "returns the value stored in the env var when set" do
        ClimateControl.modify valid_env.merge("#{var}": 'ABC') do
          expect(TahiEnv.send(reader_method_name)).to eq 'ABC'
        end
      end

      it "returns nil when not set" do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(TahiEnv.send(reader_method_name)).to be nil
        end
      end
    end
  end

  shared_examples_for 'dependent required env var' do |var:, dependent_key:|
    describe "Dependent required env var: #{var}" do
      it 'is not required to be set when dependent key is false' do
        ClimateControl.modify valid_env.merge("#{var}": nil, "#{dependent_key}": 'false') do
          expect(env.errors.full_messages).to_not include("Environment Variable: #{var} was expected to be set, but was not.")
        end
      end

      it 'is required to be set when dependent key is true' do
        ClimateControl.modify valid_env.merge("#{var}": nil, "#{dependent_key}": 'true') do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set, but was not.")
        end
      end

      it 'is required to have a value when dependent key is true' do
        ClimateControl.modify valid_env.merge("#{var}": '', "#{dependent_key}": 'true') do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to have a value, but was set to nothing.")
        end
      end

      # it 'shows up in the list of known about env vars when dependent key is true' do
      #   allow(TahiEnv).to receive("#{dependent_key}").and_return(true)
      #   expect(TahiEnv.env_vars[var.to_s]).to eq(
      #     TahiEnv::RequiredEnvVar.new(var)
      #   )
      # end
      #
      # it 'shows up in the list of known about env vars when dependent key is false' do
      #   allow(TahiEnv).to receive("#{dependent_key}").and_return(false)
      #   expect(TahiEnv.env_vars[var.to_s]).to eq(
      #     TahiEnv::OptionalEnvVar.new(var)
      #   )
      # end
    end
  end

  shared_examples_for 'optional env var' do |var:|
    describe "Optional env var: #{var}" do
      it 'is does not need to be set' do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(env.valid?).to be true
        end
      end

      it 'shows up in the list of known about env vars' do
        expect(TahiEnv.env_vars[var.to_s]).to eq(
          TahiEnv::OptionalEnvVar.new(var)
        )
      end
    end

    reader_method_name = "#{var.downcase}"
    describe "TahiEnv.#{reader_method_name}" do
      it "returns the value stored in the env var when set" do
        ClimateControl.modify valid_env.merge("#{var}": 'ABC') do
          expect(TahiEnv.send(reader_method_name)).to eq 'ABC'
        end
      end

      it "returns nil when not set" do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(TahiEnv.send(reader_method_name)).to be nil
        end
      end
    end
  end

  shared_examples_for 'required boolean env var' do |var:|
    describe "Required boolean env var: #{var}" do
      it 'shows up in the list of known about env vars' do
        expect(TahiEnv.env_vars[var.to_s]).to eq(
          TahiEnv::RequiredEnvVar.new(var)
        )
      end

      query_method_name = "#{var.downcase}?"
      describe "TahiEnv.#{query_method_name}" do
        it "is required to be set" do
          ClimateControl.modify valid_env.merge("#{var}": nil) do
            expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean, but was not set. Allowed boolean values are true (true, 1), or false (false, 0).")
          end
        end

        it "is required to a boolean value" do
          ClimateControl.modify valid_env.merge("#{var}": '') do
            expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean value, but was set to \"\". Allowed boolean values are true (true, 1), or false (false, 0).")
          end

          ClimateControl.modify valid_env.merge("#{var}": 'a string value') do
            env.valid?
            expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to be set to a boolean value, but was set to \"a string value\". Allowed boolean values are true (true, 1), or false (false, 0).")
          end
        end

        it "returns true when set to 'true' or '1'" do
          ClimateControl.modify valid_env.merge("#{var}": 'true') do
            expect(TahiEnv.send(query_method_name)).to be true
          end

          ClimateControl.modify valid_env.merge("#{var}": '1') do
            expect(TahiEnv.send(query_method_name)).to be true
          end
        end

        it "returns false when set to 'false' or '0'" do
          ClimateControl.modify valid_env.merge("#{var}": 'false') do
            expect(TahiEnv.send(query_method_name)).to be false
          end

          ClimateControl.modify valid_env.merge("#{var}": '0') do
            expect(TahiEnv.send(query_method_name)).to be false
          end
        end
      end
    end
  end

  shared_examples_for 'optional boolean env var' do |var:, default_value:|
    describe "Optional boolean env var: #{var}" do
      it 'is does not need to be set' do
        ClimateControl.modify valid_env.merge("#{var}": nil) do
          expect(env.valid?).to be true
        end
      end

      it 'shows up in the list of known about env vars' do
        expect(TahiEnv.env_vars[var.to_s]).to eq(
          TahiEnv::OptionalEnvVar.new(var)
        )
      end

      query_method_name = "#{var.downcase}?"
      describe "TahiEnv.#{query_method_name}" do
        it "defaults to #{default_value} when not set" do
          expect(TahiEnv.send(query_method_name)).to be default_value
        end

        it "returns true when set to 'true' or '1'" do
          ClimateControl.modify valid_env.merge("#{var}": 'true') do
            expect(TahiEnv.send(query_method_name)).to be true
          end

          ClimateControl.modify valid_env.merge("#{var}": '1') do
            expect(TahiEnv.send(query_method_name)).to be true
          end
        end

        it "returns false when set to 'false' or '0'" do
          ClimateControl.modify valid_env.merge("#{var}": 'false') do
            expect(TahiEnv.send(query_method_name)).to be false
          end

          ClimateControl.modify valid_env.merge("#{var}": '0') do
            expect(TahiEnv.send(query_method_name)).to be false
          end
        end
      end
    end
  end

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
      DISABLE_PUSHER_SSL_VERIFICATION: 'false',
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
      RAILS_ASSET_HOST: 'some-host',
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
  include_examples 'required env var', var: 'RAILS_ASSET_HOST'
  include_examples 'required env var', var: 'DEFAULT_MAILER_URL'
  include_examples 'optional boolean env var', var: 'DISABLE_FORCE_SSL', default_value: false
  include_examples 'required env var', var: 'FROM_EMAIL'

  # FTP
  include_examples 'required env var', var: 'FTP_DIR'
  include_examples 'required env var', var: 'FTP_HOST'
  include_examples 'required env var', var: 'FTP_PASSWORD'
  include_examples 'required env var', var: 'FTP_PORT'
  include_examples 'required env var', var: 'FTP_USER'

  # Amazon S3
  include_examples 'required env var', var: 'S3_URL'
  include_examples 'required env var', var: 'S3_BUCKET'
  include_examples 'required env var', var: 'AWS_ACCESS_KEY_ID'
  include_examples 'required env var', var: 'AWS_SECRET_ACCESS_KEY'
  include_examples 'required env var', var: 'AWS_REGION'

  # Bugsnag
  include_examples 'required env var', var: 'BUGSNAG_API_KEY'
  include_examples 'optional env var', var: 'BUGSNAG_JAVASCRIPT_API_KEY'

  # Event Stream
  include_examples 'required env var', var: 'EVENT_STREAM_WS_HOST'
  include_examples 'required env var', var: 'EVENT_STREAM_WS_PORT'

  include_examples 'optional env var', var: 'IHAT_CALLBACK_HOST'
  include_examples 'optional env var', var: 'IHAT_CALLBACK_PORT'
  include_examples 'required env var', var: 'IHAT_URL'

  include_examples 'optional env var', var: 'HIPCHAT_AUTH_TOKEN'
  include_examples 'optional env var', var: 'MAX_ABSTRACT_LENGTH'
  include_examples 'optional env var', var: 'PING_URL'
  include_examples 'optional env var', var: 'PUSHER_SOCKET_URL'
  include_examples 'optional env var', var: 'REPORTING_EMAIL'
  include_examples 'optional env var', var: 'SEGMENT_IO_WRITE_KEY'

  # Basic Auth
  include_examples 'optional boolean env var', var: 'BASIC_AUTH_REQUIRED', default_value: false
  include_examples 'dependent required env var', var: 'BASIC_HTTP_USERNAME', dependent_key: 'BASIC_AUTH_REQUIRED'
  include_examples 'dependent required env var', var: 'BASIC_HTTP_PASSWORD', dependent_key: 'BASIC_AUTH_REQUIRED'

  # CAS
  include_examples 'required boolean env var', var: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_SIGNUP_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_CALLBACK_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_CA_PATH', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_DISABLE_SSL_VERIFICATION', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_HOST', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_LOGIN_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_LOGOUT_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_PORT', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_SERVICE_VALIDATE_URL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_SSL', dependent_key: 'CAS_ENABLED'
  include_examples 'dependent required env var', var: 'CAS_UID_FIELD', dependent_key: 'CAS_ENABLED'

  # EM / Editorial Manager
  include_examples 'optional env var', var: 'EM_DATABASE'

  # Heroku
  include_examples 'optional env var', var: 'HEROKU_APP_NAME'
  include_examples 'optional env var', var: 'HEROKU_PARENT_APP_NAME'

  # Mailsafe
  include_examples 'optional env var', var: 'MAILSAFE_REPLACEMENT_ADDRESS'

  # NED
  include_examples 'required env var', var: 'NED_API_URL'
  include_examples 'required env var', var: 'NED_CAS_APP_ID'
  include_examples 'required env var', var: 'NED_CAS_APP_PASSWORD'
  include_examples 'optional boolean env var', var: 'NED_DISABLE_SSL_VERIFICATION', default_value: false
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

  # Pusher
  include_examples 'required env var', var: 'PUSHER_URL'
  include_examples 'required env var', var: 'DISABLE_PUSHER_SSL_VERIFICATION'
  include_examples 'required env var', var: 'PUSHER_VERBOSE_LOGGING'

  # Salesforce
  include_examples 'optional boolean env var', var: 'SALESFORCE_ENABLED', default_value: true
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_HOST', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_ID', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_CLIENT_SECRET', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_USERNAME', dependent_key: 'SALESFORCE_ENABLED'
  include_examples 'dependent required env var', var: 'DATABASEDOTCOM_PASSWORD', dependent_key: 'SALESFORCE_ENABLED'

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
      invalid_env = valid_env.except(:APP_NAME, :ADMIN_EMAIL)
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
