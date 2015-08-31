require 'rails_helper'

describe PaperRoleUsersController do
  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:paper){ FactoryGirl.create(:paper)}
  let(:role) { FactoryGirl.create(:role, journal: paper.journal) }
  let!(:expected_user){ FactoryGirl.create(:user)}
  let(:json_response){ JSON.parse(response.body).with_indifferent_access }

  before { sign_in(admin) }

  describe "#index" do
    before do
      assign_journal_role(paper.journal, expected_user, role)
    end

    it "lists all us available for the paper" do
      get :index, paper_id: paper.id, role_id: role.id
      serializer = UserSerializer.new(expected_user)
      expect(json_response[:users]).to include(serializer.as_json[:user])
    end
  end

end
