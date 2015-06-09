require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do

  describe "GET 'index'" do
    pending "returns all of the paper roles for the paper" do
      get :index, paper_id: 1
      expect(JSON.parse(response.body)).to eq({ paper_roles: { user_id: 1, role_id: 1 } })
    end
  end

  describe "POST 'create'" do
    let(:admin) { create :user, :site_admin }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let!(:role) { FactoryGirl.create(:role, journal: journal) }

    it "creates an assignment between a given role and the user for the paper" do
      assignment_attributes = {"role" => role.name, "user_id" => admin.id, "paper_id" => paper.id }
      post :create, "assignment" => assignment_attributes
      expect(JSON.parse(response.body)["assignment"]).to include(assignment_attributes)
    end
  end
end
