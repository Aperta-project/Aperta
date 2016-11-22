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

    it "email body is paper.decision_letter" do
      expect(email.body.raw_source).to match(decision.letter)
    end
  end
end
