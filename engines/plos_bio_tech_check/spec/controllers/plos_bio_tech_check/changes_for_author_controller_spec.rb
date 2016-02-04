require 'rails_helper'

describe PlosBioTechCheck::ChangesForAuthorController do

  let(:admin) { FactoryGirl.create :user, :site_admin, first_name: "Admin" }
  let(:paper) { FactoryGirl.create(:paper, :submitted, creator: admin) }
  let(:task) do
    FactoryGirl.create(
      :changes_for_author_task,
      paper: paper,
      participants: [admin]
    )
  end

  before do
    @routes = PlosBioTechCheck::Engine.routes
    sign_in(admin)
  end

  describe "POST 'send_email'" do
    it "return JSON success response" do
      post :send_email, id: task.id
      expect(response.status).to eq 200
      expect(res_body["success"]).to be true
    end
  end

  describe "POST 'submit_tech_check'" do
    context "with an existing ITC card" do
      let(:itc_task) { FactoryGirl.create :initial_tech_check_task, paper: paper }

      context "Paper in minor_revision state" do
        it "return JSON updated response" do
          expect(itc_task.body["round"]).to eq 1

          post :submit_tech_check, id: task.id
          expect(response.status).to eq 200
          expect(itc_task.reload.body["round"]).to eq 2
        end
      end
    end

    context "without an existing ITC card" do
      context "Paper in minor_revision state" do
        it "return JSON updated response" do
          post :submit_tech_check, id: task.id
          expect(response.status).to eq 200
        end
      end
    end
  end
end
