require "rails_helper"

describe CardPermissionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:card) { FactoryGirl.create(:card) }
  let(:role) { FactoryGirl.create(:role, name: Faker::Name.title) }
  let!(:permission) do
    FactoryGirl.create(
      :permission,
      roles: [role],
      applies_to: "Task",
      action: :edit,
      filter_by_card_id: card.id
    )
  end

  let(:permission_json) { { "id" => permission.id, "permission_action" => "edit", "filter_by_card_id" => card.id, "role_ids" => [role.id] } }
  let(:role_json) { [{ "id" => role.id, "name" => role.name, "journal_id" => role.journal.id }] }

  before do
    allow(user).to receive(:can?)
                     .with(:edit, card)
                     .and_return true
  end

  describe "#create" do
    subject(:do_request) do
      post :create,
           format: "json",
           card_id: card.id,
           permission_action: 'view',
           role_ids: [role.id]
    end

    it_behaves_like "an unauthenticated json request"

    it "creates a new permission with the correct values" do
      stub_sign_in user
      expect { do_request }.to change { Permission.count }.by(1)

      permission = Permission.find(res_body[:card_permission][:id])
      expect(permission.filter_by_card_id).to eq(card.id)
      expect(permission.action).to eq("view")
      expect(permission.roles).to eq([role])
    end

    it "attaches the new permission to the role" do
      stub_sign_in user
      expect { do_request }.to change { role.permissions.reload.count }.by(1)
      # Check deduplication
      expect { do_request }.not_to change { role.permissions.reload.count }
    end
  end

  describe "#delete" do
    subject(:do_request) { delete :destroy, format: "json", card_id: card.id, id: permission.id }

    it_behaves_like "an unauthenticated json request"

    it "deletes the permission" do
      stub_sign_in user
      expect { do_request }.to change { Permission.count }.by(-1)
    end
  end

  describe "#index" do
    subject(:do_request) { get :index, format: "json", card_id: card.id }

    it_behaves_like "an unauthenticated json request"

    it "returns a list of the cards permissions" do
      stub_sign_in user
      do_request
      expect(response.status).to be(200)
      expect(res_body).to match(hash_including("card_permissions" => [permission_json], "roles" => role_json))
    end
  end

  describe "#show" do
    subject(:do_request) { get :show, format: "json", card_id: card.id, id: permission.id }

    it_behaves_like "an unauthenticated json request"

    it "shows the permission" do
      stub_sign_in user
      do_request
      expect(res_body).to match("card_permission" => permission_json, "roles" => role_json)
    end
  end

  describe "#update" do
    subject(:do_request) { put :update, format: "json", card_id: card.id, id: permission.id, role_ids: [role.id, other_role.id] }
    let!(:other_role) { FactoryGirl.create(:role, name: Faker::Name.title) }

    it_behaves_like "an unauthenticated json request"

    it "adds the role to the role permissio" do
      stub_sign_in user
      expect { do_request }.to change { permission.roles.reload.count }
    end

    it "does not add a new role" do
      stub_sign_in user
      expect { do_request }.not_to change { Role.count }
    end
  end
end
