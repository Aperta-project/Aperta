require 'rails_helper'

describe JournalTaskTypesController do
  expect_policy_enforcement

  let(:user) { create :user, :site_admin }
  before { sign_in user }

  describe "#update" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:journal_task_type) { journal.journal_task_types.find_by(kind: "Task") }

    it "updates the thing" do
      put :update, format: :json, id: journal_task_type.id, journal_task_type: { title: "TODO ITEM", role: "editor" }
      expect(journal_task_type.reload.title).to eq("TODO ITEM")
      expect(journal_task_type.reload.role).to eq("editor")
      expect(response.status).to be(204)
    end

    context "when the task type's role is set to nil" do
      before do
        journal_task_type.update! role: "editor"
      end

      it "sets the role to the default role of the task" do
        put :update, format: :json, id: journal_task_type.id, journal_task_type: { role: nil }
        expect(journal_task_type.reload.role).to eq("user")
        expect(response.status).to be(204)
      end
    end
  end
end
