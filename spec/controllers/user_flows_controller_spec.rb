require 'spec_helper'
describe UserFlowsController do

  expect_policy_enforcement
  authorize_policy(UserFlowsPolicy, true)

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#index" do
    let!(:flow) { FactoryGirl.create(:flow, title: "My tasks", role: nil) }
    let!(:user_flow) { FactoryGirl.create(:user_flow, user: user, flow_id: flow.id) }

    context "returns a list of user_flows" do
      let(:new_title) { "Something that does not match" }

      before do
        get :index, format: :json
      end

      it "returns head 200" do
        expect(response.status).to eq(200)
      end

      it "appends the meta information for flows" do
        expect(JSON.parse(response.body)["meta"]["flows"][0]["title"]).to eq("My tasks")
      end
    end
  end

  describe "#create" do
    let!(:flow) { FactoryGirl.create(:flow, title: "My tasks") }
    let!(:user_flow) { FactoryGirl.create(:user_flow, user: user, flow_id: flow.id) }

    it "returns a serialized user_flow" do
      post :create, user_flow: {flow_id: flow.id}
      expect(JSON.parse(response.body)["user_flow"]).to_not be_nil
    end

    it "associates a flow with the current_user" do
      post :create, user_flow: {flow_id: flow.id}
      expect(user.flows).to include(flow)
    end
  end
end
