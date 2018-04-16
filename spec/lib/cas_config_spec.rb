# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'climate_control'

describe 'CasConfig' do
  describe '.omniauth_configuration' do
    subject(:config) { CasConfig.omniauth_configuration }

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
    end

    it 'returns hash with only enabled key when cas disabled' do
      ClimateControl.modify CAS_ENABLED: 'false' do
        expect(config).to eq('enabled' => false)
      end
    end
  end
end
