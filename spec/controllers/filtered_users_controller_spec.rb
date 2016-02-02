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

  def invitee_role
    "user"
  end
end

describe FilteredUsersController do
  let(:user) do
    FactoryGirl.create(:user, first_name: "Henry", last_name: "Marsh")
  end
  let(:creator) do
    FactoryGirl.create(:user, first_name: "Henry", last_name: "Bob")
  end

  let(:journal) { FactoryGirl.create(:journal) }
  let(:old_role) { FactoryGirl.create(:old_role, :editor, journal: journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal, creator: creator) }

  before do
    sign_in(user)
  end

  describe "inviting reviewers" do
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:phase) { paper.phases.create! }
    let(:task) do
      phase.tasks.create(
        type: 'TestTask',
        title: 'Test',
        old_role: 'editor',
        paper: paper
      ).extend Invitable
    end
    let(:invitation) { create :invitation, task: task, invitee: user }

    context "when a user has any invitation for expired revision cycles" do
      before do
        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
        expect(res_body["filtered_users"].count).to eq 2
        expect(res_body["filtered_users"].map { |user| user["id"] }).to include user.id
        invitation.invite!
        paper.decisions.create!
      end

      it "sends the user after a new round of revision cycle starts" do
        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
        expect(res_body["filtered_users"].count).to eq 4
        expect(res_body["filtered_users"].map { |user| user["id"] }).to include user.id
      end

      context "when the user was formerly a reviewer" do
        before { make_user_paper_reviewer user, paper }

        it "sends the user" do
          get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
          expect(res_body["filtered_users"].count).to eq 4
          expect(res_body["filtered_users"].first["id"]).to eq user.id
        end
      end
    end

    context "when a user has a pending invitation for the latest revision cycle" do
      before { invitation.invite! }

      it "does not send the user" do
        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
        expect(res_body["filtered_users"].count).to eq 3
        expect(res_body["filtered_users"].map { |user| user["id"] }).to_not include user.id
      end
    end

    context "when a user has an accepted invitation for the latest revision cycle" do
      before do
        invitation.invite!
        invitation.accept!
      end

      it "does not send the user" do
        expect(invitation.reload.state).to eq "accepted"

        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json

        expect(user.invitations.first).to eq invitation

        expect(res_body["filtered_users"].count).to eq 3
        expect(res_body["filtered_users"].map { |user| user["id"] }).to_not include user.id
      end
    end

    context "when a user does not have a pending invitation for the latest revision cycle" do
      before { paper.decisions.create! }

      it 'sends the user' do
        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
        expect(res_body["filtered_users"].count).to eq 2
        expect(res_body["filtered_users"].map { |user| user["id"] }).to include user.id
      end

      it "sends the user even if the user was formerly a paper reviewer" do
        make_user_paper_reviewer user, paper
        get :uninvited_users, paper_id: paper.id, query: 'Henry', format: :json
        expect(res_body["filtered_users"].count).to eq 2
        expect(res_body["filtered_users"].map { |user| user["id"] }).to include user.id
      end
    end

    # Create a total of:
    #  3 Random Users
    #  3 Editors
    #  2 Admins
    context "when searching from select2 dropdowns" do
      let(:rando2)    { FactoryGirl.create :user, email: "reviewer@example.com" }
      let(:rando3)    { FactoryGirl.create :user }
      let(:rando4)    { FactoryGirl.create :user }
      let(:editor1)   { FactoryGirl.create :user, email: "editor@example.com", last_name: "Doe" }
      let(:editor2)   { FactoryGirl.create :user }
      let(:editor3)   { FactoryGirl.create :user }
      let(:admin1)    { FactoryGirl.create :user, email: "admin@example.com", first_name: "John" }
      let(:admin2)    { FactoryGirl.create :user }

      before do
        assign_journal_role(journal, editor1, :editor)
        assign_journal_role(journal, editor2, :editor)
        assign_journal_role(journal, editor3, :editor)
        assign_journal_role(journal, admin1, :admin)
        assign_journal_role(journal, admin2, :admin)
      end

      describe "#editors" do
        it "returns editors" do
          pending 'Waiting on a filtering implementation for new roles'
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
          get :editors, paper_id: paper.id, query: "doe", format: :json
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

      describe "query all users" do
        it "filters reviewers by name" do
          get :uninvited_users, paper_id: paper.id, query: "john", format: :json
          expect(res_body["filtered_users"].count).to eq 1
          expect(res_body["filtered_users"].first["id"]).to eq admin1.id
          expect(res_body["filtered_users"].first["email"]).to eq admin1.email
        end
      end
    end
  end
end
