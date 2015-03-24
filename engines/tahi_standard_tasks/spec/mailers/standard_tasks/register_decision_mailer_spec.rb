require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionMailer do

  let(:paper) {
    FactoryGirl.create(:paper,
                       title: "Paper Title",
                       short_title: "Short Paper Title",
                       decision_letter: "Here's body text of a Decision Letter")
  }

  let(:task) {
    FactoryGirl.create(:task,
                       title: "Register Decision Report",
                       role: 'reviewer',
                       type: "TahiStandardTasks::RegisterDecisionTask",
                       paper: paper,
                       completed: true)
  }

  let(:email) {
    described_class.notify_author_email(task_id: task.id)
  }

  describe "#notify_author_email" do
    it "sends email to the author's email" do
      expect(email.to).to eq([paper.creator.email])
    end

    it "includes email subject" do
      expect(email.subject).to eq "A Decision has been Registered on #{paper.title}"
    end

    it "email body is paper.decision_letter" do
      expect(email.body.raw_source).to eq paper.decision_letter + "\n"
    end
  end
end
