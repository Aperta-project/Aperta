require 'rails_helper'

describe TahiStandardTasks::FundersController do
  routes { TahiStandardTasks::Engine.routes }
  expect_policy_enforcement

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:task) { FactoryGirl.create(:task, type: "TahiStandardTasks::FinancialDisclosureTask") }
  let!(:funder) { TahiStandardTasks::Funder.create!(name: "Starfleet", task_id: task.id) }

  before do
    sign_in user
  end

  describe "#create" do
    it "creates a funder" do
      expect do
        post :create, format: :json, funder: { task_id: task.id, name: "Batelle" }
      end.to change { TahiStandardTasks::Funder.count }.by(1)
      expect(response).to be_success
    end
  end

  describe "#update" do
    it "patches the funder" do
      put :update, format: :json, id: funder.id, funder: { name: "Galactic Empire" }
      expect(response).to be_success
      expect(funder.reload.name).to eq("Galactic Empire")
    end
  end

  describe "#destroy" do
    it "eliminates the funder" do
      expect do
        delete :destroy, format: :json, id: funder.id
      end.to change { TahiStandardTasks::Funder.count }.by(-1)
      expect(response).to be_success
    end
  end

end
