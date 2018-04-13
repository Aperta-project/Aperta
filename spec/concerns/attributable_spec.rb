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
