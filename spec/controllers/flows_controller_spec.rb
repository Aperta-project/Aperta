require 'rails_helper'
describe FlowsController do

  authorize_policy(FlowsPolicy, true)

  let(:journal) { FactoryGirl.create(:journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#index" do
    let(:role) { assign_journal_role(journal, user, :admin) }
    let!(:flow) { FactoryGirl.create(:flow, role: role, title: "My tasks") }

    context "when user has access" do
      action_policy(RolesPolicy, :show, true)

      it "responds head 200" do
        get :index, { format: :json, role_id: role.id }
        expect(response.status).to eq(200)
      end
    end

    context "when user does not have access" do
      action_policy(RolesPolicy, :show, false)

      it "responds head 403" do
        get :index, { format: :json, role_id: role.id }
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    expect_policy_enforcement
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
