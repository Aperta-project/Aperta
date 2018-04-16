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

describe Readyable do
  let(:create_fake_readyables_table) do
    silence_stream($stdout) do
      ActiveRecord::Schema.define do
        create_table :fake_readyables, force: true do |t|
          t.string :value
        end
      end
    end
  end

  let(:klass) do
    create_fake_readyables_table
    Class.new(ActiveRecord::Base) do
      include Readyable
      self.table_name = 'fake_readyables'
    end
  end

  let(:ready_obj) do
    klass.new
  end

  describe 'an including class' do
    it "doesn't have ready and ready_issues properties by default" do
      expect(ready_obj.ready).to be_falsey
      expect(ready_obj.ready_issues).to be_falsey
    end

    it "can be initialized for ready properties" do
      ready_obj.ready_init
      expect(ready_obj.ready).to be_truthy
      expect(ready_obj.ready_issues).to be_truthy
    end
  end
end
