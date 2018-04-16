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

describe MergeField do
  class ThirdLevelSampleContext < TemplateContext
    def baz
      42
    end
  end

  class SecondLevelSampleContext < TemplateContext
    subcontext :bar, type: :third_level_sample
    def blah
      'blah'
    end
  end

  class TopLevelSampleContext < TemplateContext
    subcontexts :foo, type: :second_level_sample
    def simple
      'so simple'
    end
  end

  describe '#merge_fields' do
    it 'expands subcontext merge fields' do
      expanded = [
        { name: :foo, is_array: true, children: [
          { name: :bar, children: [
            { name: :baz }
          ] },
          { name: :blah }
        ] },
        { name: :simple }
      ]
      merge_fields = MergeField.list_for(TopLevelSampleContext)
      expect(merge_fields).to eq(expanded)
    end
  end
end
