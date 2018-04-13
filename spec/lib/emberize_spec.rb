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
