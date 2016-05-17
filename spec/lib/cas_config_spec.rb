require 'rails_helper'
require 'climate_control'

describe 'CasConfig' do
  describe '.load_configuration' do
    subject(:config) { CasConfig.load_configuration }

    describe 'returns hash of arguments when enabled' do
      let(:valid_cas_env) do
        {
          CAS_ENABLED: 'true',
          CAS_SIGNUP_URL: 'http://sample.tahi-project.org/signup',
          CAS_CALLBACK_URL: 'http://sample.tahi-project.org/callback',
          CAS_SSL_VERIFY: 'true',
          CAS_HOST: 'sample.tahi-project.org',
          CAS_LOGIN_URL: '/cas/login',
          CAS_LOGOUT_URL: '/cas/logout',
          CAS_PORT: '443',
          CAS_SERVICE_VALIDATE_URL: '/cas/p3/serviceValidate',
          CAS_SSL: 'false'
        }
      end

      around do |example|
        ClimateControl.modify valid_cas_env do
          example.run
        end
      end

      it { expect(config['ssl']).to eq(false) }
      it { expect(config['ssl_verify']).to eq(true) }
      it { expect(config['host']).to eq('sample.tahi-project.org') }
      it { expect(config['port']).to eq('443') }
      it { expect(config['service_validate_url']).to eq('/cas/p3/serviceValidate') }
      it { expect(config['callback_url']).to eq('http://sample.tahi-project.org/callback') }
      it { expect(config['logout_url']).to eq('/cas/logout') }
      it { expect(config['login_url']).to eq('/cas/login') }
      it { expect(config['logout_full_url']).to eq('http://sample.tahi-project.org/cas/logout') }
    end

    it 'returns hash with only enabled key when cas disabled' do
      ClimateControl.modify CAS_ENABLED: 'false' do
        expect(config).to eq('enabled' => false)
      end
    end
  end
end
