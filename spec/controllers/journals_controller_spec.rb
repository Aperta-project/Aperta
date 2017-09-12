require 'rails_helper'

describe JournalsController do

  let(:user) { create :user }
  let(:journal) { FactoryGirl.create(:journal) }

  let! (:setting_template) do
    FactoryGirl.create(:setting_template,
     key: "Journal",
     setting_name: "coauthor_confirmation_enabled",
     value_type: 'boolean',
     boolean_value: true)
  end

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
