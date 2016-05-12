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
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to set, but was not.")
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
          expect(env.errors.full_messages).to_not include("Environment Variable: #{var} was expected to set, but was not.")
        end
      end

      it 'is required to be set when dependent key is true' do
        ClimateControl.modify valid_env.merge("#{var}": nil, "#{dependent_key}": 'true') do
          expect(env.errors.full_messages).to include("Environment Variable: #{var} was expected to set, but was not.")
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

  shared_examples_for 'optional boolean env var' do |var:, default_value:|
    describe "Optional boolean env var: #{var}" do
      it 'is does not need to b set' do
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
      DISABLE_PUSHER_SSL_VERIFICATION: 'false',
      FTP_HOST: 'ftp://foo.bar',
      FTP_USER: 'the-oracle',
      FTP_PASSWORD: 'tiny-green-characters',
      FTP_PORT: '21',
      FTP_DIR: 'where/the/wild/things/are',
      IHAT_URL: 'http://ihat.tahi-project.com',
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
      RAILS_SECRET_TOKEN: 'secret-token'
    }
  end

  include_examples 'required env var', var: 'APP_NAME'
  include_examples 'required env var', var: 'ADMIN_EMAIL'
  include_examples 'required env var', var: 'PASSWORD_AUTH_ENABLED'
  include_examples 'required env var', var: 'RAILS_ENV'
  include_examples 'required env var', var: 'RAILS_SECRET_TOKEN'

  include_examples 'required env var', var: 'FTP_DIR'
  include_examples 'required env var', var: 'FTP_HOST'
  include_examples 'required env var', var: 'FTP_PASSWORD'
  include_examples 'required env var', var: 'FTP_PORT'
  include_examples 'required env var', var: 'FTP_USER'

  include_examples 'required env var', var: 'S3_URL'
  include_examples 'required env var', var: 'S3_BUCKET'
  include_examples 'required env var', var: 'AWS_ACCESS_KEY_ID'
  include_examples 'required env var', var: 'AWS_SECRET_ACCESS_KEY'
  include_examples 'required env var', var: 'AWS_REGION'

  include_examples 'required env var', var: 'BUGSNAG_API_KEY'
  include_examples 'optional env var', var: 'BUGSNAG_JAVASCRIPT_API_KEY'

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

  include_examples 'optional env var', var: 'CAS_SIGNUP_URL'
  include_examples 'optional boolean env var', var: 'CAS_ENABLED', default_value: false

  # Heroku
  include_examples 'optional env var', var: 'HEROKU_APP_NAME'
  include_examples 'optional env var', var: 'HEROKU_PARENT_APP_NAME'

  # Mailsafe
  include_examples 'optional env var', var: 'MAILSAFE_REPLACEMENT_ADDRESS'

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

  # Sidekiq
  include_examples 'optional env var', var: 'SIDEKIQ_CONCURRENCY'
end
