require 'rails_helper'

describe JournalTaskTypesController do
  expect_policy_enforcement

  let(:user) { create :user, :site_admin }
  before { sign_in user }

  describe "#update" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:journal_task_type) { journal.journal_task_types.find_by(kind: "Task") }

    it "updates the thing" do
      put :update, format: :json, id: journal_task_type.id, journal_task_type: { title: "TODO ITEM", old_role: "editor" }
      expect(journal_task_type.reload.title).to eq("TODO ITEM")
      expect(journal_task_type.reload.old_role).to eq("editor")
      expect(response.status).to be(204)
    end

    context "when the task type's old_role is set to nil" do
      before do
        journal_task_type.update! old_role: "editor"
      end

      it "sets the old_role to the default old_role of the task" do
        put :update, format: :json, id: journal_task_type.id, journal_task_type: { old_role: nil }
        expect(journal_task_type.reload.old_role).to eq("user")
        expect(response.status).to be(204)
      end
    end
  end
end
