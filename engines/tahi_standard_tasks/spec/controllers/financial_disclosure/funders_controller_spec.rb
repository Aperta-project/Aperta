require 'rails_helper'

describe TahiStandardTasks::FundersController do
  routes { TahiStandardTasks::Engine.routes }

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:task) { FactoryGirl.create(:task, type: "TahiStandardTasks::FinancialDisclosureTask") }
  let!(:funder) { TahiStandardTasks::Funder.create!(name: "Starfleet", task_id: task.id) }

  before do
    sign_in user
  end

  describe "#create" do
    def do_request
      post :create, format: :json, funder: { task_id: task.id, name: "Batelle" }
    end

    it "creates a funder" do
      funder_count = TahiStandardTasks::Funder.count
      do_request
      expect(TahiStandardTasks::Funder.count).to eq(2)
      expect(response).to be_success
    end

    context "without permission" do
      before do
        allow_any_instance_of(User).to receive(:can?).and_return(false)
      end

      it 'returns a 403 without permission' do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    def do_request
      put :update, format: :json, id: funder.id,
                   funder: { name: "Galactic Empire" }
    end

    it "patches the funder" do
      do_request
      expect(response).to be_success
      expect(funder.reload.name).to eq("Galactic Empire")
    end

    context "without permission" do
      before do
        allow_any_instance_of(User).to receive(:can?).and_return(false)
      end

      it 'returns a 403 without permission' do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#destroy" do
    def do_request
      delete :destroy, format: :json, id: funder.id
    end

    it "eliminates the funder" do
      do_request
      expect(TahiStandardTasks::Funder.count).to eq(0)
      expect(response).to be_success
    end

    context "without permission" do
      before do
        allow_any_instance_of(User).to receive(:can?).and_return(false)
      end

      it 'returns a 403 without permission' do
        do_request
        expect(response.status).to eq(403)
      end
    end
  end
end
