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

describe TahiStandardTasks::ExportDelivery do
  let!(:paper) do
    FactoryGirl.create(:paper, publishing_state: 'accepted')
  end
  subject(:export_delivery) { FactoryGirl.build(:export_delivery, paper: paper, destination: 'apex') }

  describe 'validations' do
    it 'is valid' do
      expect(export_delivery.valid?).to be(true)
    end

    it 'requires a user' do
      export_delivery.user = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a paper' do
      export_delivery.paper = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a paper to be accepted' do
      export_delivery.paper.publishing_state = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a task' do
      export_delivery.task = nil
      expect(export_delivery.valid?).to be(false)
    end
  end
end
