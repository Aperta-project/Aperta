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

describe PlosBilling::Paper::Salesforce do
  let(:salesforce_manuscript_update_worker) do
    class_double(PlosBilling::SalesforceManuscriptUpdateWorker)
      .as_stubbed_const(transfer_nested_constants: true)
  end
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:paper) { FactoryGirl.build_stubbed(:paper) }

  before do
    allow(Paper).to receive(:find).with(paper.id).and_return(paper)
    allow(paper).to receive(:creator) { user }
  end

  describe "subscribes to state changes" do
    before do
      expect(salesforce_manuscript_update_worker)
        .to receive(:perform_async).with(paper.id).once
    end

    it "finds or creates Salesforce Manuscript on submitted" do
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "finds or creates Salesforce Manuscript on accept" do
      described_class.call("tahi:paper:accepted", record: paper)
    end

    it "finds or creates Salesforce Manuscript on reject" do
      described_class.call("tahi:paper:rejected", record: paper)
    end

    it "finds or creates Salesforce Manuscript on withdraw" do
      described_class.call("tahi:paper:withdrawn", record: paper)
    end
  end
end
