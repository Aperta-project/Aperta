require 'spec_helper'
require 'climate_control'
require 'active_model'
require File.dirname(__FILE__) + '/../../lib/tahi_env'

shared_examples_for 'required env var' do |var:|
  let(:valid_env) do
    { FTP_HOST: 'ftp://foo.bar', FTP_PORT: '2600' }
  end

  describe var do
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
  end
end

describe TahiEnv do
  subject(:env) { TahiEnv.new.tap(&:validate) }

  include_examples 'required env var', var: 'FTP_DIRECTORY'
  include_examples 'required env var', var: 'FTP_HOST'
  include_examples 'required env var', var: 'FTP_PASSWORD'
  include_examples 'required env var', var: 'FTP_PORT'
  include_examples 'required env var', var: 'FTP_USER'
end
