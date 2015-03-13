require 'rails_helper'

describe FilteredUsersController do
  let(:current_user) { create :user }
  let(:journal) { create(:journal) }
  let(:paper) {create(:paper, journal: journal)}

  before do
    sign_in(current_user)
  end

  describe "#editors" do
    it "returns an empty list of the editors from a journal" do
      get :editors, paper_id: paper.id, format: :json
      json = json(response.body)
      expect(json[:filtered_users]).to be_empty
    end

    it "returns a list of the editors from a journal" do
      possible_editor = create(:user, first_name: "Jhon", last_name: "Doe", email: "jhondoe@example.com")
      assign_journal_role(journal, possible_editor, :editor)
      get :editors, paper_id: paper.id, format: :json
      json = json(response.body)

      expect(json[:filtered_users].count).to eq 1
      expect(json[:filtered_users].first[:id]).to eq possible_editor.id
      expect(json[:filtered_users].first[:full_name]).to eq "Jhon Doe"
      expect(json[:filtered_users].first[:email]).to eq "jhondoe@example.com"
    end

    it "returns a filtered list based on the query param sent" do
      possible_editor1 = create(:user, first_name: "Jhon", last_name: "Doe", email: "jhondoe@example.com")
      possible_editor2 = create(:user, first_name: "Mr", last_name: "Tahi", email: "tahi@example.com")
      assign_journal_role(journal, possible_editor1, :editor)
      assign_journal_role(journal, possible_editor2, :editor)
      get :editors, paper_id: paper.id, query: "mr", format: :json
      json = json(response.body)
      expect(json[:filtered_users].count).to eq 1
      expect(json[:filtered_users].first[:full_name]).to eq "Mr Tahi"
      expect(json[:filtered_users].first[:email]).to eq "tahi@example.com"
    end
  end

  describe "#admins" do
    it "returns an empty list of the admins from a journal" do
      get :admins, paper_id: paper.id, format: :json
      json = json(response.body)
      expect(json[:filtered_users]).to be_empty
    end

    it "returns a list of the admins from a journal" do
      possible_admin = create(:user, first_name: "Jhon", last_name: "Doe", email: "jhondoe@example.com")
      assign_journal_role(journal, possible_admin, :admin)
      get :admins, paper_id: paper.id, format: :json
      json = json(response.body)

      expect(json[:filtered_users].count).to eq 1
      expect(json[:filtered_users].first[:id]).to eq possible_admin.id
      expect(json[:filtered_users].first[:full_name]).to eq "Jhon Doe"
      expect(json[:filtered_users].first[:email]).to eq "jhondoe@example.com"
    end
  end

  describe "#reviewers" do
    it "returns an empty list of the reviewers from a journal" do
      get :reviewers, paper_id: paper.id, format: :json
      json = json(response.body)
      expect(json[:filtered_users]).to be_empty
    end

    it "returns a list of the reviewers from a journal" do
      possible_reviewer = create(:user, first_name: "Jhon", last_name: "Doe", email: "jhondoe@example.com")
      assign_journal_role(journal, possible_reviewer, :reviewer)
      get :reviewers, paper_id: paper.id, format: :json
      json = json(response.body)

      expect(json[:filtered_users].count).to eq 1
      expect(json[:filtered_users].first[:id]).to eq possible_reviewer.id
      expect(json[:filtered_users].first[:full_name]).to eq "Jhon Doe"
      expect(json[:filtered_users].first[:email]).to eq "jhondoe@example.com"
    end
  end
end