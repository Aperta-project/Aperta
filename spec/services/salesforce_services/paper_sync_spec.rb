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
require File.dirname(__FILE__) + '/sync_examples'

describe SalesforceServices::PaperSync do
  subject(:paper_sync) do
    described_class.new(paper: paper, salesforce_api: salesforce_api)
  end
  let(:paper) { instance_double(Paper, id: 99) }
  let(:salesforce_api) { class_double(SalesforceServices::API) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires a paper' do
      paper_sync.paper = nil
      expect(paper_sync.valid?).to be(false)
    end
  end

  it_behaves_like 'salesforce sync object'

  describe '#sync!' do
    it 'finds or creates the corresponding manuscript in salesforce' do
      expect(salesforce_api).to receive(:find_or_create_manuscript)
        .with(paper: paper)
      paper_sync.sync!
    end

    context 'when the paper_sync is not valid' do
      it 'raises an error communicating why its not valid' do
        paper_sync.paper = nil
        expect do
          paper_sync.sync!
        end.to raise_error(
          SalesforceServices::SyncInvalid,
          /The paper cannot be sent to Salesforce.*Paper can't be blank/m
        )
      end
    end
  end
end
