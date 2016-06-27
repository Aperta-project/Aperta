require 'rails_helper'

describe 'Emberize' do
  describe '.class_name' do
    let(:class_foo) { double('Foo class', name: 'Foo') }
    let(:class_foo_bar) { double('FooBar class', name: 'FooBar') }
    let(:class_foo_bar_baz) { double('FooBarBaz class', name: 'FooBarBaz') }

    it 'lowerCamelCases the class name' do
      expect(Emberize.class_name(class_foo)).to eq('foo')
      expect(Emberize.class_name(class_foo_bar)).to eq('fooBar')
      expect(Emberize.class_name(class_foo_bar_baz)).to eq('fooBarBaz')
    end
  end
end
