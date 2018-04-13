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

describe PreprintDoiIncrementer do
  let(:incrementer) { PreprintDoiIncrementer.create }

  describe '#succ!' do
    it 'increments the singletons value by one' do
      start_value = incrementer.value
      incrementer.send(:succ!)
      expect(incrementer.value).to eq(start_value + 1)
      incrementer.send(:succ!)
      expect(incrementer.value).to eq(start_value + 2)
    end
  end

  describe '#to_doi' do
    it 'creates a 7 digit string from the value with leading zeros' do
      incrementer.value = 1
      expect(incrementer.send(:to_doi)).to eq("0000001")
      incrementer.value = 46
      expect(incrementer.send(:to_doi)).to eq("0000046")
      incrementer.value = 397
      expect(incrementer.send(:to_doi)).to eq("0000397")
      incrementer.value = 4890
      expect(incrementer.send(:to_doi)).to eq("0004890")
      incrementer.value = 34908
      expect(incrementer.send(:to_doi)).to eq("0034908")
      incrementer.value = 129362
      expect(incrementer.send(:to_doi)).to eq("0129362")
      incrementer.value = 2349087
      expect(incrementer.send(:to_doi)).to eq("2349087")
    end
  end
end
