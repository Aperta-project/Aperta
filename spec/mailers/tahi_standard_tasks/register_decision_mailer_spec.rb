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

describe TahiStandardTasks::RegisterDecisionMailer do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) do
    FactoryGirl.create(:paper,
      :with_creator,
      journal: journal,
      title: "Paper Title")
  end

  let(:decision) do
    paper.decisions.create!(
      letter: "Body text of a Decision Letter",
      verdict: "accept"
    )
  end

  let(:email_with_no_fields_specified) do
    described_class.notify_author_email(to_field: nil, subject_field: nil, decision_id: decision.id)
  end

  describe "#notify_author_email" do
    context 'with to field and subject field empty' do
      it "sends email to the author with the correct subject and decision letter" do
        aggregate_failures do
          expect(email_with_no_fields_specified.to).to eq([paper.creator.email])
          expect(email_with_no_fields_specified.subject).to eq "A decision has been registered on the manuscript, \"#{paper.title}\""
          expect(email_with_no_fields_specified.body.raw_source).to match(decision.letter)
        end
      end
    end

    context 'with to field and subject field populated with custom values' do
      let(:email_to_arbitrary) do
        described_class.notify_author_email(to_field: 'arb@example.com', subject_field: 'Your Submission', decision_id: decision.id)
      end
      it "sends email to the author's email with a custom subject, containing the decision letter" do
        aggregate_failures do
          expect(email_to_arbitrary.to).to eq(['arb@example.com'])
          expect(email_to_arbitrary.subject).to eq 'Your Submission'
          expect(email_to_arbitrary.body.raw_source).to match(decision.letter)
        end
      end
    end
  end
end
