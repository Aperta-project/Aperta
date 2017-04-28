require "rails_helper"

describe CardPermissionsController do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:user) { FactoryGirl.create(:user) }
  let(:card) { FactoryGirl.create(:card, journal: journal) }
  let(:role) { FactoryGirl.create(:role, journal: journal, name: Faker::Name.title) }
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

  before do
    allow(user).to receive(:can?)
                     .with(:edit, card)
                     .and_return true
    allow(user).to receive(:can?)
                     .with(:administer, card.journal)
                     .and_return true
  end

  describe "#create" do
    subject(:do_request) do
      post :create,
           format: "json",
           card_permission: {
             card_id: card.id,
             permission_action: 'view',
             role_ids: [role.id]
           }
    end

    it_behaves_like "an unauthenticated json request"

    it "creates a new permission with the correct values" do
      stub_sign_in user
      expect { do_request }.to change { Permission.count }.by(1)

      expect(response.status).to be(201)
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
    subject(:do_request) { delete :destroy, format: "json", id: permission.id }

    it_behaves_like "an unauthenticated json request"

    it "deletes the permission" do
      stub_sign_in user
      expect { do_request }.to change { Permission.count }.by(-1)
    end
  end

  describe "#show" do
    subject(:do_request) { get :show, format: "json", id: permission.id }

    it_behaves_like "an unauthenticated json request"

    it "shows the permission" do
      stub_sign_in user
      do_request
      expect(res_body).to match("card_permission" => permission_json)
    end
  end

  describe "#update" do
    subject(:do_request) do
      put :update,
          format: "json",
          id: permission.id,
          card_permission: {
            card_id: card.id,
            role_ids: [role.id, other_role.id]
          }
    end

    let!(:other_role) { FactoryGirl.create(:role, journal: journal, name: Faker::Name.title) }

    it_behaves_like "an unauthenticated json request"

    it "adds the role to the role permission" do
      stub_sign_in user
      expect { do_request }.to change { permission.roles.reload.count }
    end

    it "does not add a new role" do
      stub_sign_in user
      expect { do_request }.not_to change { Role.count }
    end
  end
end
