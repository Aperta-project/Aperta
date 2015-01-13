require 'rails_helper'

describe JournalTaskTypesController do
  expect_policy_enforcement

  let(:user) { create :user, :site_admin }
  before { sign_in user }

  describe "#update" do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:journal_task_type) { journal.journal_task_types.first }

    it "updates the thing" do
      put :update, format: :json, id: journal_task_type.id, journal_task_type: { title: "TODO ITEM" }
      expect(response.status).to be(204)
      expect(journal_task_type.reload.title).to eq("TODO ITEM")
    end
  end
end
