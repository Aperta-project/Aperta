require 'rails_helper'

describe RolesController do

  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let!(:role) { FactoryGirl.create(:role, journal: journal) }

  before { sign_in(admin) }

  describe "#index" do
    context "when the journal_id is provided" do
      it "lists all roles" do
        get :index, journal_id: journal.id
        expected_role = {"id" => role.id,
                         "kind" => role.kind,
                         "name" => role.name,
                         "required" => false,
                         "can_administer_journal" => false,
                         "can_view_assigned_manuscript_managers" => false,
                         "can_view_all_manuscript_managers" => false,
                         "can_view_flow_manager" => false,
                         "journal_id" => role.journal_id,
                         "flow_ids" => []}
        expect(JSON.parse(response.body)["roles"]).to include(expected_role)
      end
    end
  end

  describe "#create" do
    it "creates a role" do
      expect do
        post(:create, role: FactoryGirl.attributes_for(:role, journal_id: journal.id), format: :json)
      end.to change { journal.roles.count }.by(1)

      expect(response.status).to be(201)
    end
  end

  describe "#update" do
    it "updates a role" do
      put(:update, id: role.id, role: { name: "Super Duper Admin" }, format: :json)
      expect(response.status).to be(200)
      expect(role.reload.name).to eq("Super Duper Admin")
    end
  end

  describe "#delete" do
    it "deletes a role" do
      delete(:destroy, id: role.id, format: :json)
      expect(response.status).to be(204)
      assert(!Role.where(id: role).exists?)
    end
  end

end
