require 'rails_helper'

describe TahiStandardTasks::ApexDeliveriesController do
  routes { TahiStandardTasks::Engine.routes }

  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :send_to_apex_task, paper: paper }

  subject(:do_request) do
    post :create, format: :json, apex_delivery: { task_id: task.to_param }
  end

  context "the current user can send to apex" do
    before do
      stub_sign_in user
      allow(user).to receive(:can?)
        .with(:send_to_apex, paper)
        .and_return true
    end

    it "creates an apex delivery" do
      expect do
        do_request
        expect(response).to have_http_status(200)
      end.to change { TahiStandardTasks::ApexDelivery.count }.by 1
    end
  end

  context "the current user can't send to apex" do
    before do
      stub_sign_in user
      allow(user).to receive(:can?)
        .with(:send_to_apex, paper)
        .and_return false
    end

    it "fails and returns a 403" do
      expect do
        do_request
        expect(response).to have_http_status(403)
      end.to change { TahiStandardTasks::ApexDelivery.count }.by 0
    end
  end
end
