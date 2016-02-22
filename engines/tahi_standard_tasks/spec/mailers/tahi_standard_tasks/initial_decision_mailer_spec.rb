require 'rails_helper'

describe TahiStandardTasks::InitialDecisionMailer do

  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_integration_journal,
      :with_creator,
      title: 'Paper Title'
    )
  end

  let(:task) do
    FactoryGirl.create(:initial_decision_task,
                       paper: paper,
                       completed: true)
  end

  let(:decision) do
    paper.decisions.create!(
      letter: "Body text of a Decision Letter",
      verdict: "reject"
    )
  end

  let(:email) do
    described_class.notify(decision_id: decision.id)
  end

  describe "#notify" do
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
