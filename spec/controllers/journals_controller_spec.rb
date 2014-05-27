require 'spec_helper'

describe JournalsController do

  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :admin) }
  let(:journal) { FactoryGirl.create(:journal) }

  before { sign_in user }

  context "#index" do
    it "will allow access" do
      get :index, format: :json
      expect(response.status).to eq(200)
    end
  end

  context "#show" do
    it "will allow access" do
      get :show, id: journal.id, format: :json
      expect(response.status).to eq(200)
    end
  end
end
