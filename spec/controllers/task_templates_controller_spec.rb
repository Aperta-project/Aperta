require 'spec_helper'

describe TaskTemplatesController do
  let(:user) { create :user, :site_admin }
  before { sign_in user }

  let(:phase_template) { FactoryGirl.create(:phase_template) }
  let(:task_template) { FactoryGirl.create(:task_template, phase_template: phase_template) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:journal_task_type) { journal.journal_task_types.first }

  expect_policy_enforcement

  it "creates a record" do
    post :create, format: :json, task_template: { phase_template_id: phase_template.id, journal_task_type_id: journal_task_type.id, title: "Valid Title" }
    expect(response.status).to eq(201)
  end

  it "updates a record" do
    put :update, format: :json, id: task_template.id, task_template: { phase_template_id: phase_template.id, journal_task_type_id: journal_task_type.id }
    expect(response.status).to eq(204)
  end

  it "deletes a record" do
    delete :destroy, format: :json, id: task_template.id
    expect(response.status).to eq(204)
  end
end
