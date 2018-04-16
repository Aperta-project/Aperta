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

describe TahiStandardTasks::InitialDecisionMailer do
  let(:paper) { FactoryGirl.build_stubbed(:paper, title: 'Paper Title') }
  let(:decision) do
    FactoryGirl.build_stubbed(
      :decision,
      letter: 'Body text of a Decision Letter',
      verdict: 'reject',
      paper: paper
    )
  end
  let(:paper_creator) { FactoryGirl.build_stubbed(:user)}

  let(:email) do
    described_class.notify(decision_id: decision.id)
  end

  describe "#notify" do
    before do
      allow(Decision).to receive(:find).
        with(decision.id).
        and_return decision

      allow(paper).to receive(:creator).and_return paper_creator
    end

    it "sends email to the author's email" do
      expect(email.to).to eq([paper.creator.email])
    end

    it "includes email subject" do
      expect(email.subject).to eq "A decision has been registered on the manuscript, \"Paper Title\""
    end

    it "email body is the decisions's letter" do
      expect(email.body.raw_source).to match(decision.letter)
    end
  end
end
