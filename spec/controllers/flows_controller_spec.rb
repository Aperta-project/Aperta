require 'spec_helper'
describe FlowsController do

  expect_policy_enforcement
  authorize_policy(FlowsPolicy, true)

  let(:journal) { FactoryGirl.create(:journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#update" do
    let!(:flow) { FactoryGirl.create(:flow, role: role, title: "My tasks") }

    context "changes the title" do
      let(:new_title) { "New title" }

      it "returns head 200" do
        put :update, { format: 'json', id: flow.id, flow: { title: new_title } }
        expect(response.status).to eq(200)
        expect(Flow.find(flow.id).title).to eq(new_title)
      end
    end
  end
end
