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
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  before do
    assign_journal_role(journal, user, :reviewer)
    sign_in(user)
  end

  describe "#reviewers /filtered_users/reviewers/:paper_id" do
    let!(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:phase) { paper.phases.create! }
    let(:task) do
      phase.tasks.create(type: "TestTask",
                         title: "Test",
                         role: "reviewer").extend Invitable
    end
    let(:invitation) { create :invitation, task: task, invitee: user }

    context "when a user has any invitation for expired revision cycles" do
      before do
        get :reviewers, paper_id: paper.id, format: :json
        expect(res_body["filtered_users"].count).to eq 1
        expect(res_body["filtered_users"].first["id"]).to eq user.id
        invitation.invite!
        paper.decisions.create!
      end

      it "sends the user after a new round of revision cycle starts" do
        get :reviewers, paper_id: paper.id, format: :json
        expect(res_body["filtered_users"].count).to eq 1
        expect(res_body["filtered_users"].first["id"]).to eq user.id
      end

      context "when the user is already a reviewer" do
        before { make_user_paper_reviewer user, paper }

        it "sends the user" do
          get :reviewers, paper_id: paper.id, format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq user.id
        end
      end
    end

    context "when a user has a pending invitation for the latest revision cycle" do
      before { invitation.invite! }

      it "does not send the user" do
        get :reviewers, paper_id: paper.id, format: :json
        expect(res_body["filtered_users"]).to be_empty
      end
    end

    context "when a user does not have a pending invitation for the latest revision cycle" do
      before { paper.decisions.create! }

      it 'sends the user' do
        get :reviewers, paper_id: paper.id, format: :json
        expect(res_body["filtered_users"].count).to eq 1
        expect(res_body["filtered_users"].first["id"]).to eq user.id
        expect(res_body["filtered_users"].first["email"]).to eq user.email
      end

      it "sends the user even if the user is already a paper reviewer" do
        make_user_paper_reviewer user, paper
        get :reviewers, paper_id: paper.id, format: :json
        expect(res_body["filtered_users"].count).to eq 1
        expect(res_body["filtered_users"].first["id"]).to eq user.id
        expect(res_body["filtered_users"].first["email"]).to eq user.email
      end
    end

    # Create a total of:
    #  4 Reviewers
    #  3 Editors
    #  2 Admins
    context "when searching from select2 dropdowns" do
      let(:reviewer2) { FactoryGirl.create :user, email: "reviewer@example.com", first_name: "Jane", last_name: "Doe" }
      let(:reviewer3) { FactoryGirl.create :user }
      let(:reviewer4) { FactoryGirl.create :user }
      let(:editor1)   { FactoryGirl.create :user, email: "editor@example.com", first_name: "Jane", last_name: "Roe" }
      let(:editor2)   { FactoryGirl.create :user }
      let(:editor3)   { FactoryGirl.create :user }
      let(:admin1)    { FactoryGirl.create :user, email: "admin@example.com", first_name: "John", last_name: "Doe" }
      let(:admin2)    { FactoryGirl.create :user }

      before do
        assign_journal_role(journal, reviewer2, :reviewer)
        assign_journal_role(journal, reviewer3, :reviewer)
        assign_journal_role(journal, reviewer4, :reviewer)
        assign_journal_role(journal, editor1, :editor)
        assign_journal_role(journal, editor2, :editor)
        assign_journal_role(journal, editor3, :editor)
        assign_journal_role(journal, admin1, :admin)
        assign_journal_role(journal, admin2, :admin)
      end

      describe "#editors" do
        it "returns editors" do
          get :editors, paper_id: paper.id, format: :json
          expect(res_body["filtered_users"].count).to eq 3
        end

        it "filters editors by email" do
          get :editors, paper_id: paper.id, query: "editor", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq editor1.id
          expect(res_body["filtered_users"].first["email"]).to eq editor1.email
        end

        it "filters editors by name" do
          get :editors, paper_id: paper.id, query: "roe", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq editor1.id
          expect(res_body["filtered_users"].first["email"]).to eq editor1.email
        end
      end

      describe "#admins" do
        it "returns admins" do
          get :admins, paper_id: paper.id, format: :json
          expect(res_body["filtered_users"].count).to eq 2
        end

        it "filters admins by email" do
          get :admins, paper_id: paper.id, query: "admin", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq admin1.id
          expect(res_body["filtered_users"].first["email"]).to eq admin1.email
        end

        it "filters admins by name" do
          get :admins, paper_id: paper.id, query: "john", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq admin1.id
          expect(res_body["filtered_users"].first["email"]).to eq admin1.email
        end
      end

      describe "#reviewers" do
        it "returns reviewers" do
          get :reviewers, paper_id: paper.id, format: :json
          expect(res_body["filtered_users"].count).to eq 4
        end

        it "filters reviewers by email" do
          get :reviewers, paper_id: paper.id, query: "reviewer", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq reviewer2.id
          expect(res_body["filtered_users"].first["email"]).to eq reviewer2.email
        end

        it "filters reviewers by name" do
          get :reviewers, paper_id: paper.id, query: "jane", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq reviewer2.id
          expect(res_body["filtered_users"].first["email"]).to eq reviewer2.email
        end
      end
    end
  end
end
