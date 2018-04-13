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
  describe "validating paper accepted" do
    it "the paper must be accepted when delivering to apex" do
      delivery = FactoryGirl.build(:export_delivery, destination: 'apex')
      expect(delivery).to have(1).errors_on(:paper)
      delivery.paper.update(publishing_state: 'accepted')
      expect(delivery).to be_valid
    end

    it "the paper can be in any publishing_state when delivering to preprint" do
      delivery = FactoryGirl.build(:export_delivery, destination: 'preprint')
      expect(delivery).to be_valid
    end

    it "the paper can be in any publishing_state when delivering to em" do
      delivery = FactoryGirl.build(:export_delivery, destination: 'em')
      expect(delivery).to be_valid
    end
  end
end
