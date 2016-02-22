require 'rails_helper'

describe FlowsController do
  authorize_policy(FlowsPolicy, true)

  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "#index" do
    let(:old_role) { assign_journal_role(journal, user, :admin) }
    let!(:flow) { FactoryGirl.create(:flow, old_role: old_role, title: "My tasks") }

    context "when user has access" do
      action_policy(OldRolesPolicy, :show, true)

      it "responds head 200" do
        get :index, { format: :json, old_role_id: old_role.id }
        expect(response.status).to eq(200)
      end
    end

    context "when user does not have access" do
      action_policy(OldRolesPolicy, :show, false)

      it "responds head 403" do
        get :index, { format: :json, old_role_id: old_role.id }
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    expect_policy_enforcement
    let!(:flow) { FactoryGirl.create(:flow, old_role: old_role, title: "My tasks") }
    let(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

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
