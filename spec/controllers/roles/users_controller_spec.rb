require 'rails_helper'

describe OldRoles::UsersController do
  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let!(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

  before do
    old_role.users << admin
    old_role.save!
    sign_in(admin)
  end

  describe "GET 'index'" do
    it "lists all of the users that belong to that old_role in the journal" do
      get :index, old_role_id: old_role.id
      expected_response = {
        "id" => admin.id,
        "full_name" => admin.full_name,
        "first_name" => admin.first_name,
        "avatar_url" => admin.avatar.url,
        "username" => admin.username
      }

      expect(res_body["users"]).to include(expected_response)
    end
  end
end
