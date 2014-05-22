require 'spec_helper'

describe JournalsController do
  let(:journal) { FactoryGirl.create(:journal) }

  describe "#index" do
    subject(:do_request) do
      get :index, format: :json
    end

    context "where the user is an admin" do
      let(:admin) { FactoryGirl.create(:user, :admin) }
      let(:role) { FactoryGirl.create(:role, :admin, journal: journal) }
      let!(:journal_role) { JournalRole.create!(user: admin, journal: journal, role: role) }

      before do
        sign_in admin
      end

      it "allows access to journals" do
        do_request
        journal_ids = JSON.parse(response.body)["journals"].map{ |j| j["id"] }
        expect(journal_ids).to match_array([journal.id])
      end
    end

    context "where the user is not an admin" do
      let(:editor) { FactoryGirl.create(:user) }
      let(:role) { FactoryGirl.create(:role, :editor, journal: journal) }
      let!(:journal_role) { JournalRole.create!(user: editor, journal: journal, role: role) }

      before do
        sign_in editor
      end

      it "does not allow access to journals" do
        do_request
        journal_ids = JSON.parse(response.body)["journals"].map{ |j| j["id"] }
        expect(journal_ids).to be_empty
      end
    end
  end
end
