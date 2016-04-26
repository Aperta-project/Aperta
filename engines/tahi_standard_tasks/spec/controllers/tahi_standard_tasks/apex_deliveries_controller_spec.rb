require 'rails_helper'

describe TahiStandardTasks::ApexDeliveriesController do
  routes { TahiStandardTasks::Engine.routes }

  let(:author) { FactoryGirl.create :user }
  let(:internal_editor) do
    FactoryGirl.create(:user).tap { |u| assign_internal_editor_role paper, u }
  end
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) { FactoryGirl.create :paper, journal: journal, creator: author }
  let(:task) { FactoryGirl.create :send_to_apex_task, paper: paper }

  subject(:do_request) do
    post :create, format: :json, apex_delivery: { task_id: task.to_param }
  end

  context "the current user is an internal editor" do
    before do
      sign_in internal_editor
    end

    it "allows an internal editor to send to apex" do
      expect do
        do_request
        expect(response).to have_http_status(200)
      end.to change { TahiStandardTasks::ApexDelivery.count }.by 1
    end
  end

  context "the current user is an internal editor" do
    before do
      sign_in author
    end

    it "does't allow non-staff members to send to apex" do
      expect do
        do_request
        expect(response).to have_http_status(403)
      end.to change { TahiStandardTasks::ApexDelivery.count }.by 0
    end
  end
end
