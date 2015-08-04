require 'rails_helper'

describe TahiStandardTasks::ReviewerMailer do
  let(:reviewer_task) { FactoryGirl.create(:task) }
  let(:paper) { reviewer_task.paper }
  let(:reviewer) { FactoryGirl.create(:user) }
  let(:assigner) { FactoryGirl.create(:user) }

  describe ".reviewer_accepted" do
    context "with an assigner" do
      let(:email) { described_class.reviewer_accepted(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: assigner.id) }

      it "has correct subject line" do
        expect(email.subject).to eq "Reviewer invitation was accepted on the manuscript, \"#{paper.display_title}\""
      end

      it "sends to the assigner" do
        expect(email.to).to match_array(assigner.email)
      end

      it "contains the paper title" do
        expect(email.body).to match(reviewer_task.paper.title)
      end

      it "contains link to the task" do
        expect(email.body).to match(%r{\/papers\/#{paper.id}\/tasks\/#{reviewer_task.id}})
      end
    end

    context "without assigner" do
      let(:email) { described_class.reviewer_accepted(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: nil) }

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe ".reviewer_declined" do
    context "with an assigner" do
      let(:email) { described_class.reviewer_declined(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: assigner.id) }

      it "has correct subject line" do
        expect(email.subject).to eq "Reviewer invitation was declined on the manuscript, \"#{paper.display_title}\""
      end

      it "sends to the assigner" do
        expect(email.to).to match_array(assigner.email)
      end

      it "contains the paper title" do
        expect(email.body).to match(reviewer_task.paper.title)
      end

      it "contains link to the task" do
        expect(email.body).to match(%r{\/papers\/#{paper.id}\/tasks\/#{reviewer_task.id}})
      end
    end

    context "without assigner" do
      let(:email) { described_class.reviewer_declined(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: nil) }

      it "does not send" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
