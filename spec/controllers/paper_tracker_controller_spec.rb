require 'rails_helper'

describe PaperTrackerController do
  let(:user) { FactoryGirl.create :user }
  let(:assigned_journal) { FactoryGirl.create :journal }
  let(:unassigned_journal) { FactoryGirl.create :journal }
  let!(:user_role) do
    role = FactoryGirl.create(
      :role,
      :flow_manager,
      journal: assigned_journal)
    UserRole.create(role: role, user: user)
   end

  before { sign_in user }

  describe "index" do
    context "there's a paper in the assigned journal" do
      let!(:paper) { FactoryGirl.create(:paper, :submitted, journal: assigned_journal) }
      let(:response) { get :index, format: :json }
      let(:response_papers) { JSON.parse(response.body)['papers'] }

      it "it appears in the list" do
        expect(response_papers.count).to be(1)
      end
    end
  end

  describe "index" do
    context "there's a paper in the unassigned journal" do
      let!(:paper) { FactoryGirl.create(:paper, :submitted, journal: unassigned_journal) }
      let(:response) { get :index, format: :json }
      let(:response_papers) { JSON.parse(response.body)['papers'] }

      it "does not appear" do
        expect(response_papers.count).to be(0)
      end
    end
  end

  describe "index" do
    context "there's an unsubmitted paper in the assigned journal" do
      let!(:paper) { FactoryGirl.create(:paper, journal: assigned_journal) }
      let(:response) { get :index, format: :json }
      let(:response_papers) { JSON.parse(response.body)['papers'] }

      it "does not appear" do
        expect(response_papers.count).to be(0)
      end
    end
  end
end
