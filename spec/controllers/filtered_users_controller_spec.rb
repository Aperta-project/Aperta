require 'rails_helper'

class TestTask < Task
  include TaskTypeRegistration
  include Invitable

  register_task default_title: "Test Task", default_role: "user"

  def invitation_invited(_invitation)
    "invited"
  end

  def invitation_accepted(_invitation)
    "accepted"
  end
end

describe FilteredUsersController do
  let(:user) { create :user }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:role) { FactoryGirl.create(:role, :reviewer, journal: journal) }
  let(:paper) do
    paper = FactoryGirl.create(:paper)
    paper.paper_roles.create!(role: PaperRole::REVIEWER, user: user)
    paper
  end

  before do
    assign_journal_role(journal, user, :reviewer)
    sign_in(user)
  end

  describe "#reviewers /filtered_users/reviewers/:journal_id" do
    # before do
    #   let(:phase) { FactoryGirl.create(:phase) }
    #   let(:task) { phase.tasks.create(type: "TestTask", title: "Test", role: "reviewer") }
    #   let(:invitation) { FactoryGirl.build(:invitation, task: task) }
    # end
    context "when a user has a pending invitation" do
      it "does not send the user"
    end

    context "when a user does not have a pending invitation" do
      context "when the user is already a reviewer" do
        it "does not send the user" do
          get :reviewers, journal_id: journal.id, format: :json
          res_body = JSON.parse response.body
          expect(res_body["filtered_users"]).to be_empty
        end
      end

      it "sends the user" do
        get :reviewers, journal_id: journal.id, format: :json
        res_body = JSON.parse response.body
        expect(res_body["filtered_users"].count).to eq 1
        expect(res_body["filtered_users"].first["id"]).to eq user.id
        expect(res_body["filtered_users"].first["email"]).to eq user.email
      end
    end
  end
end
