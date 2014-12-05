require 'spec_helper'
describe UserFlowsController do

  expect_policy_enforcement
  authorize_policy(UserFlowsPolicy, true)

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#update" do
    let!(:role_flow) { FactoryGirl.create(:role_flow, title: "My tasks") }
    let!(:flow) { FactoryGirl.create(:user_flow, user: user, role_flow_id: role_flow.id) }

    context "title does not map to a template" do
      let(:new_title) { "Something that does not match" }

      it "returns head 200" do
        put :update, { format: 'json', id: flow.id, user_flow: { title: new_title } }
        expect(response.status).to eq(200)
        expect(RoleFlow.find(flow.id).title).to eq(new_title)
      end
    end
  end
end
