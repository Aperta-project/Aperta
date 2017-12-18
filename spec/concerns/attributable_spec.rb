require 'rails_helper'

describe Attributable do
  # Use a fake test class to make things easy.
  # Unlike Task, System is almost never used
  class FakeTestSystem < System
    include Attributable
    has_attributes boolean: [:bool_attr], string: [:string_attr]
  end

  let(:klass) do
    FakeTestSystem
  end

  let(:instance) { klass.create }

  describe 'setting values' do
    describe 'boolean values' do
      it 'sets truthy values' do
        instance.bool_attr = true
        expect(instance.reload.bool_attr).to eq(true)
      end

      it 'sets falsey values' do
        instance.bool_attr = false
        expect(instance.reload.bool_attr).to eq(false)
      end
    end

    describe 'string values' do
      it 'sets truthy values for strings' do
        instance.string_attr = true
        expect(instance.reload.string_attr).to eq('t')
      end

      it 'sets falsey values for strings' do
        instance.string_attr = false
        expect(instance.reload.string_attr).to eq('f') # fails on master
      end
    end
  end

  describe '#inspect' do
    let(:word) { Faker::Lorem.word }

    it 'includes the attributes' do
      instance.bool_attr = true
      instance.string_attr = word
      expect(instance.inspect).to match(/\*string_attr: #{word}/)
      expect(instance.inspect).to match(/\*bool_attr: true/)
    end
  end
end
