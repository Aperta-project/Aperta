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

describe Typesetter::FinancialDisclosureSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:custom_card_task) }
  let(:output) { serializer.serializable_hash }
  let(:aaron_funder_repetition) { FactoryGirl.create(:repetition, task: task) }
  let(:alex_funder_repetition) { FactoryGirl.create(:repetition, task: task) }
  let(:author_received_funding) { true }

  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

  let(:received_funding_question) do
    [{
      ident: 'financial_disclosures--author_received_funding',
      answer: author_received_funding,
      value_type: 'boolean'
    }]
  end

  let(:funders) { [Funder.new([], nil), Funder.new([], nil)] }
  let(:stubbed_financial_disclosure_statement) { double(funding_statement: "here is my statement", funders: funders) }

  before do
    allow_any_instance_of(described_class).to receive(:financial_disclosure_statement).and_return(stubbed_financial_disclosure_statement)
  end

  it 'has competing interests fields' do
    expect(output.keys).to contain_exactly(
      :author_received_funding,
      :funding_statement,
      :funders
    )
  end

  describe "without any funder answers" do
    let(:funders) { [] }

    it 'works' do
      expect(output[:author_received_funding]).to eq(nil)
      expect(output[:funding_statement]).to eq("here is my statement")
      expect(output[:funders]).to eq([])
    end
  end

  describe 'author_received_funding' do
    before { AnswerableFactory.create(task, questions: received_funding_question) }

    it 'marks whether the author received funding' do
      expect(output[:author_received_funding]).to eq(true)
    end
  end

  describe 'funding_statement' do
    it 'collects the funding statements from the funders' do
      expect(output[:funding_statement]).to eq("here is my statement")
    end
  end

  describe 'funders' do
    it 'serializes the funders using the typesetter serializer' do
      expect(output[:funders].length).to eq(2)
    end
  end
end
