require 'rails_helper'

describe TahiStandardTasks::ReviewerMailer do
  add_template_helper ClientRouteHelper

  let(:reviewer_task) { FactoryGirl.create(:task) }
  let(:paper) { reviewer_task.paper }
  let(:reviewer) { FactoryGirl.create(:user) }
  let(:assigner) { FactoryGirl.create(:user) }

  context ".reviewer_accepted" do
    let(:email) { described_class.reviewer_accepted(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: assigner.id) }

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

  context ".reviewer_declined" do
    let(:email) { described_class.reviewer_declined(invite_reviewer_task_id: reviewer_task.id, reviewer_id: reviewer.id, assigner_id: assigner.id) }

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
end
