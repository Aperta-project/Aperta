require 'rails_helper'

describe PaperRolesController do
  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:paper){ FactoryGirl.create(:paper)}
  let!(:expected_role) { FactoryGirl.create(:old_role, journal: paper.journal) }
  let(:json_response){ JSON.parse(response.body).with_indifferent_access }

  before { sign_in(admin) }

  describe "#index" do
    it "lists all old_roles available for the paper" do
      get :index, paper_id: paper.id
      serializer = OldRoleSerializer.new(expected_role)
      expect(json_response[:old_roles]).to include(serializer.as_json[:old_role])
    end
  end

end
