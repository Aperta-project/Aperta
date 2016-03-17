require 'rails_helper'

describe JournalsController do

  let(:user) { create :user }
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
