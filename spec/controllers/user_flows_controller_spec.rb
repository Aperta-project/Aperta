require 'rails_helper'
describe UserFlowsController do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  context "policy enforced methods" do
    expect_policy_enforcement
    authorize_policy(UserFlowsPolicy, true)

    describe "#index" do
      let!(:flow) { FactoryGirl.create(:flow, title: "My tasks", old_role: nil) }
      let!(:user_flow) { FactoryGirl.create(:user_flow, user: user, flow_id: flow.id) }

      context "returns a list of user_flows" do
        let(:new_title) { "Something that does not match" }

        before do
          get :index, format: :json
        end

        it "returns head 200" do
          expect(response.status).to eq(200)
        end
      end
    end

    describe "#create" do
      let!(:flow) { FactoryGirl.create(:flow, title: "My tasks") }
      let!(:user_flow) { FactoryGirl.create(:user_flow, user: user, flow_id: flow.id) }

      it "returns a serialized user_flow" do
        post :create, user_flow: {flow_id: flow.id}
        expect(res_body["user_flow"]).to_not be_nil
      end

      it "associates a flow with the current_user" do
        post :create, user_flow: {flow_id: flow.id}
        expect(user.flows).to include(flow)
      end
    end
  end

  describe "#potential_flows" do
    let!(:flow) { FactoryGirl.create(:flow, title: "My tasks", old_role: nil) }

    before do
      get :potential_flows, format: :json
    end

    it "returns potential flow json" do
      expect(res_body["flows"][0]["title"]).to eq("My tasks")
    end
  end
end
