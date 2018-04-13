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

describe FinancialDisclosureStatement do
  subject { described_class.new(task.paper) }

  let(:card) { FactoryGirl.create(:card, :versioned) }
  let(:card_version) { card.latest_card_version }
  let(:task) { FactoryGirl.create(:custom_card_task, card_version: card_version) }
  let(:root_content) { FactoryGirl.create(:card_content, :root) }
  let(:repeat_card_content) { FactoryGirl.create(:card_content, parent: root_content, card_version: card_version, ident: "funder--repeat") }
  let(:funder_repetition) { FactoryGirl.create(:repetition, task: task, card_content: repeat_card_content) }

  let(:received_funding_question) do
    [
      {
        ident: 'financial_disclosures--author_received_funding',
        answer: true,
        value_type: 'boolean'
      }
    ]
  end

  let(:funder_one) do
    [
      {
        ident: 'funder--name',
        answer: 'aaron',
        value_type: 'text',
        repetition: funder_repetition
      },
      {
        ident: 'funder--grant_number',
        answer: 'aa-123',
        value_type: 'text',
        repetition: funder_repetition
      },
      {
        ident: 'funder--website',
        answer: 'aaron.funds',
        value_type: 'text',
        repetition: funder_repetition
      },
      {
        ident: 'funder--additional_comments',
        answer: 'does not expect a return on this investment',
        value_type: 'text',
        repetition: funder_repetition
      },
      {
        ident: 'funder--had_influence',
        answer: 'true',
        value_type: 'boolean',
        repetition: funder_repetition
      },
      {
        ident: 'funder--had_influence--role_description',
        answer: 'constant meddling',
        value_type: 'text',
        repetition: funder_repetition
      }
    ]
  end

  before do
    AnswerableFactory.create(task, card: card, questions: (received_funding_question + funder_one))
  end

  describe "#funding_statement" do
    context "with funders" do
      it "accumulates the funding statement from all funders" do
        expect(subject.funding_statement).to eq("aaron aaron.funds (grant number aa-123). does not expect a return on this investment. constant meddling.")
      end
    end

    context "with no funders" do
      let(:funder_one) { [] }

      it "gives default statement when there are no funders" do
        expect(subject.funding_statement).to match(/received no specific funding/)
      end
    end
  end

  describe "#funders" do
    context "with funders" do
      it "returns all funders on a paper" do
        expect(subject.funders.length).to eq(1)
        expect(subject.funders.first.name).to eq("aaron")
      end
    end

    context "with no funders" do
      let(:funder_one) { [] }

      it "returns an empty array" do
        expect(subject.funders).to eq([])
      end
    end
  end

  describe "#asked?" do
    context "with funders and received funding answer" do
      it "returns true" do
        expect(subject.asked?).to be_truthy
      end
    end

    context "with no funders, but with a received funding answer" do
      let(:funder_one) { [] }

      it "returns true" do
        expect(subject.asked?).to be_truthy
      end
    end

    context "with no funders and no received funding answer" do
      let(:funder_one) { [] }
      let(:received_funding_question) { [] }

      it "returns false" do
        expect(subject.asked?).to be_falsy
      end
    end
  end
end
