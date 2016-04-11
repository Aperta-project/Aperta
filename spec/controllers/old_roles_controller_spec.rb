require 'rails_helper'

describe OldRolesController do

  expect_policy_enforcement

  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let!(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

  before { sign_in(admin) }

  describe "#index" do
    context "when the journal_id is provided" do
      it "lists all old_roles" do
        get :index, journal_id: journal.id
        expected_role = {"id" => old_role.id,
                         "kind" => old_role.kind,
                         "name" => old_role.name,
                         "required" => false,
                         "can_administer_journal" => false,
                         "can_view_assigned_manuscript_managers" => false,
                         "can_view_all_manuscript_managers" => false,
                         "journal_id" => old_role.journal_id}
        expect(JSON.parse(response.body)["old_roles"]).to include(expected_role)
      end
    end
  end

  describe "#create" do
    it "creates a old_role" do
      expect do
        post(:create, old_role: FactoryGirl.attributes_for(:old_role, journal_id: journal.id), format: :json)
      end.to change { journal.old_roles.count }.by(1)

      expect(response.status).to be(201)
    end
  end

  describe "#update" do
    it "updates a old_role" do
      put(:update, id: old_role.id, old_role: { name: "Super Duper Admin" }, format: :json)
      expect(response.status).to be(200)
      expect(old_role.reload.name).to eq("Super Duper Admin")
    end
  end

  describe "#delete" do
    it "deletes a old_role" do
      delete(:destroy, id: old_role.id, format: :json)
      expect(response.status).to be(204)
      assert(!OldRole.where(id: old_role).exists?)
    end
  end

end
