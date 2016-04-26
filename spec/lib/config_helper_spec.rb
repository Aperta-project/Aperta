require 'spec_helper'
require 'config_helper'
require 'climate_control'

describe ConfigHelper do
  describe '#read_boolean_env' do
    it 'should return false if variable not set' do
      ClimateControl.modify 'FOO': nil do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(false)
      end
    end

    it 'should return false if variable is set to `false`' do
      ClimateControl.modify 'FOO' => 'false' do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(false)
      end
    end

    it 'should return true if variable is set to `true`' do
      ClimateControl.modify 'FOO' => 'true' do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(true)
      end
    end

    it 'should return true if variable is set to `1`' do
      ClimateControl.modify 'FOO' => '1' do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(true)
      end
    end

    it 'should return ignore case' do
      ClimateControl.modify 'FOO' => 'TrUe' do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(true)
      end

      ClimateControl.modify 'FOO' => 'FaLsE' do
        expect(ConfigHelper.read_boolean_env('FOO')).to be(false)
      end
    end

    it 'should fail otherwise' do
      [' false', '0', ''].each do |val|
        ClimateControl.modify 'FOO': val do
          expect do
            ConfigHelper.read_boolean_env('FOO')
          end.to raise_exception(ConfigException)
        end
      end
    end
  end
end
