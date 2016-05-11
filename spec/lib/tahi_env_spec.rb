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

  shared_examples_for 'optional env var' do |var:|
    describe "Optional env var: #{var}" do
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
      FTP_HOST: 'ftp://foo.bar',
      FTP_USER: 'the-oracle',
      FTP_PASSWORD: 'tiny-green-characters',
      FTP_PORT: '21',
      FTP_DIR: 'where/the/wild/things/are',
      S3_URL: 'http://tahi-test.amazonaws.com',
      S3_BUCKET: 'tahi',
      AWS_ACCESS_KEY_ID: 'DNCDCC55F',
      AWS_SECRET_ACCESS_KEY: '98Abc754',
      AWS_REGION: 'us-west'
    }
  end

  include_examples 'required env var', var: 'APP_NAME'
  include_examples 'required env var', var: 'ADMIN_EMAIL'

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

  include_examples 'optional env var', var: 'IHAT_CALLBACK_HOST'
  include_examples 'optional env var', var: 'IHAT_CALLBACK_PORT'
  include_examples 'optional env var', var: 'REPORTING_EMAIL'

  include_examples 'optional boolean env var', var: 'CAS_ENABLED', default_value: false
end
