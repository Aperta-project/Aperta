require 'spec_helper'
require 'climate_control'
require 'active_model'
require File.dirname(__FILE__) + '/../../lib/tahi_env'

describe TahiEnv do
  subject(:env) { TahiEnv.new.tap(&:validate) }

  let(:valid_env) do
    {
      FTP_HOST: 'ftp://foo.bar',
      FTP_USER: 'the-oracle',
      FTP_PASSWORD: 'tiny-green-characters',
      FTP_PORT: '21',
      FTP_DIRECTORY: 'where/the/wild/things/are'
    }
  end

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
  end

  include_examples 'required env var', var: 'FTP_DIRECTORY'
  include_examples 'required env var', var: 'FTP_HOST'
  include_examples 'required env var', var: 'FTP_PASSWORD'
  include_examples 'required env var', var: 'FTP_PORT'
  include_examples 'required env var', var: 'FTP_USER'

  include_examples 'optional env var', var: 'IHAT_CALLBACK_HOST'
  include_examples 'optional env var', var: 'IHAT_CALLBACK_PORT'
end
