require 'spec_helper'
require 'climate_control'
require File.dirname(__FILE__) + '/../../../lib/tahi_env'

describe TahiEnv::OptionalEnvVar do

  describe '#boolean?' do
    it 'returns true when it is a boolean env var' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      expect(env_var.boolean?).to be(true)
    end

    it 'returns false otherwise' do
      env_var = TahiEnv::EnvVar.new(:FOO)
      expect(env_var.boolean?).to be(false)
    end
  end

  describe '#==' do
    it 'is equal to an env var of the same class and key (ignoring type)' do
      env_var_1 = TahiEnv::OptionalEnvVar.new(:foo, :boolean)
      env_var_2 = TahiEnv::OptionalEnvVar.new(:foo, :string)
      expect(env_var_1).to eq(env_var_2)
      expect(env_var_2).to eq(env_var_1)
    end

    it 'is not equal to another env var with a different key' do
      env_var_1 = TahiEnv::OptionalEnvVar.new(:foo)
      env_var_2 = TahiEnv::OptionalEnvVar.new(:bar)
      expect(env_var_1).to_not eq(env_var_2)
      expect(env_var_2).to_not eq(env_var_1)
    end

    it 'is not equal to another env var with same key, but different class' do
      env_var_1 = TahiEnv::OptionalEnvVar.new(:foo)
      env_var_2 = TahiEnv::RequiredEnvVar.new(:foo)
      expect(env_var_1).to_not eq(env_var_2)
      expect(env_var_2).to_not eq(env_var_1)
    end
  end

  describe '#raw_value_from_env' do
    it 'returns the raw value from the env' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      ClimateControl.modify FOO: '0' do
        expect(env_var.raw_value_from_env).to eq('0')
      end
    end
  end

  describe '#value' do
    it 'returns the value stored as-is in the ENV when it has no type' do
      env_var = TahiEnv::EnvVar.new(:FOO)
      ClimateControl.modify FOO: 'hey ya' do
        expect(env_var.value).to eq('hey ya')
      end

      ClimateControl.modify FOO: 'true' do
        expect(env_var.value).to eq('true')
      end
    end

    it 'returns the default value when there is no value in the env' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean, default: true)
      ClimateControl.modify FOO: nil do
        expect(env_var.value).to be(true)
      end
    end

    it 'returns true when a boolean and env value is "true"' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      ClimateControl.modify FOO: 'true' do
        expect(env_var.value).to be(true)
      end
    end

    it 'returns true when a boolean and env value is "1"' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      ClimateControl.modify FOO: '1' do
        expect(env_var.value).to be(true)
      end
    end

    it 'returns true when a boolean and env value is "false"' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      ClimateControl.modify FOO: 'false' do
        expect(env_var.value).to be(false)
      end
    end

    it 'returns true when a boolean and env value is "0"' do
      env_var = TahiEnv::EnvVar.new(:FOO, :boolean)
      ClimateControl.modify FOO: '0' do
        expect(env_var.value).to be(false)
      end
    end
  end

  describe '#to_s' do
    it 'returns a human readable string' do
      env_var = TahiEnv::EnvVar.new(:foo, :boolean)
      expect(env_var.to_s).to eq('Environment Variable: foo')
    end

    context 'and additional details is provided' do
      it 'includes the additional details' do
        env_var = TahiEnv::EnvVar.new(
          :foo,
          :boolean,
          additional_details: 'say what bar?'
        )
        expected_message = 'Environment Variable: foo (say what bar?)'
        expect(env_var.to_s).to eq(expected_message)
      end
    end
  end
end
