require 'rails_helper'

describe Roles::UsersController do
  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let!(:role) { FactoryGirl.create(:role, journal: journal) }

  before do
    role.users << admin
    role.save!
    sign_in(admin)
  end

  describe "GET 'index'" do
    it "lists all of the users that belong to that role in the journal" do
      get :index, role_id: role.id
      expected_response = {"id" => admin.id,
                           "full_name" => admin.full_name,
                           "first_name" => admin.first_name,
                           "avatar_url" => admin.avatar.url,
                           "username" => admin.username,
                           "email" => admin.email}

      expect(res_body["users"]).to include(expected_response)
    end
  end
end
