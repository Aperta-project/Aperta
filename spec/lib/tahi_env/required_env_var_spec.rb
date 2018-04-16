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

require 'spec_helper'
require 'climate_control'
require File.dirname(__FILE__) + '/../../../lib/tahi_env'

describe TahiEnv::RequiredEnvVar do
  describe '#to_s' do
    it 'returns a human readable string' do
      env_var = TahiEnv::RequiredEnvVar.new(:foo, :boolean)
      expect(env_var.to_s).to eq('Environment Variable: foo (required)')
    end

    context 'and additional details is provided' do
      it 'includes the additional details' do
        env_var = TahiEnv::RequiredEnvVar.new(
          :foo,
          :boolean,
          additional_details: 'if bar?'
        )
        expected_message = 'Environment Variable: foo (required if bar?)'
        expect(env_var.to_s).to eq(expected_message)
      end
    end
  end
end
