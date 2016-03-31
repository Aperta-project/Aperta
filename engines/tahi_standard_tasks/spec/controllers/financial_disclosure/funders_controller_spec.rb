require 'rails_helper'

describe TahiStandardTasks::FundersController do
  routes { TahiStandardTasks::Engine.routes }

  let(:user) { FactoryGirl.create(:user, :site_admin) }
  let(:task) { FactoryGirl.create(:financial_disclosure_task) }
  let!(:funder) { TahiStandardTasks::Funder.create!(name: "Starfleet", task_id: task.id) }
  let(:additional_comments) { "Darmok and Jalad at Tanagra" }

  before do
    sign_in user
  end

  describe "#create" do
    def do_request
      post :create,
           format: :json,
           funder: {
             task_id: task.id,
             name: "Batelle",
             additional_comments: additional_comments
           }
    end

    it "creates a funder" do
      allow_any_instance_of(User).to receive(:can?).with(:edit, task)
        .and_return(true)

      expect { do_request }.to change { TahiStandardTasks::Funder.count }.by 1
      expect(response).to be_success
      task = TahiStandardTasks::Funder.last
      expect(task.additional_comments).to eq additional_comments
    end

    context "without permission" do
      it "returns a 403 without permission" do
        allow_any_instance_of(User).to receive(:can?).with(:edit, task)
          .and_return(false)
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
      allow_any_instance_of(User).to receive(:can?).with(:edit, task)
        .and_return(true)
      do_request

      expect(response).to be_success
      expect(funder.reload.name).to eq("Galactic Empire")
    end

    context "without permission" do
      it 'returns a 403 without permission' do
        allow_any_instance_of(User).to receive(:can?).with(:edit, task)
          .and_return(false)
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
      funder_count = TahiStandardTasks::Funder.count
      allow_any_instance_of(User).to receive(:can?).with(:edit, task)
        .and_return(true)
      do_request

      expect(TahiStandardTasks::Funder.count).to eq(funder_count - 1)
      expect(response).to be_success
    end

    context "without permission" do
      it 'returns a 403 without permission' do
        allow_any_instance_of(User).to receive(:can?).with(:edit, task)
          .and_return(false)
        do_request

        expect(response.status).to eq(403)
      end
    end
  end
end
