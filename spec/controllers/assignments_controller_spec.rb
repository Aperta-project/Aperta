require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do

  describe "GET 'index'" do
    pending "returns all of the paper roles for the paper" do
      get :index, paper_id: 1
      expect(JSON.parse(response.body)).to eq({ paper_roles: { user_id: 1, role_id: 1 } })
    end
  end

  describe "POST 'create'" do
    it "creates an assignment between a given role and the user for the paper" do
      post :create, paper_id: 1, role_id: 1, user_id: 2
      expect(JSON.parse(response.body)).to eq({ paper_roles: { user_id: 1, role_id: 1 } })
    end
  end
end
