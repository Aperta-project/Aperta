require 'spec_helper'

describe FlowsController do
  render_views
  expect_policy_enforcement

  let(:user) { create :user, :site_admin }

  before { sign_in user }

  describe 'POST create' do
    subject(:do_request) do
      post :create, {
        format: 'json',
        flow: { title: "done" }
      }
    end

    it "creates a flow" do
      expect { do_request }.to change(Flow, :count).by(1)
    end
  end

  describe 'DELETE destroy' do
    let!(:flow) { FactoryGirl.create(:flow, user: user) }

    subject(:do_request) do
      delete :destroy, {
        format: 'json',
        id: flow.id
      }
    end

    it "destroys a flow" do
      expect { do_request }.to change(Flow, :count).by(-1)
    end
  end
end
