require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionMailer do

  let(:paper) {
    FactoryGirl.create(:paper,
                       :with_integration_journal,
                       :with_creator,
                       title: "Paper Title",
                       short_title: "Short Paper Title")
  }

  let(:task) {
    FactoryGirl.create(:task,
                       title: "Register Decision Report",
                       old_role: 'reviewer',
                       type: "TahiStandardTasks::RegisterDecisionTask",
                       paper: paper,
                       completed: true)
  }

  let(:decision) {
    paper.decisions.create!(
      letter: "Body text of a Decision Letter",
      verdict: "accept"
    )
  }

  let(:email) {
    described_class.notify_author_email(decision_id: decision.id)
  }

  describe "#notify_author_email" do
    it "sends email to the author's email" do
      expect(email.to).to eq([paper.creator.email])
    end

    it "includes email subject" do
      expect(email.subject).to eq "A decision has been registered on the manuscript, \"#{paper.title}\""
    end

    it "email body is paper.decision_letter" do
      expect(email.body.raw_source).to match(decision.letter)
    end
  end
end
