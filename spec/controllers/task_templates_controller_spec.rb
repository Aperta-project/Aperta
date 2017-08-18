require 'rails_helper'

describe TaskTemplatesController do
  let(:user) { create :user, :site_admin }
  before { sign_in user }

  let(:journal) { FactoryGirl.create(:journal) }
  let(:manuscript_manager_template) {
    FactoryGirl.create(:manuscript_manager_template, journal: journal)
  }

  let(:phase_template) {
    FactoryGirl.create(:phase_template, manuscript_manager_template: manuscript_manager_template)
  }
  let(:setting) {
    FactoryGirl.create(:setting, name: 'ithenticate_automation')
  }
  let(:task_template) {
    FactoryGirl.create(:task_template,
    phase_template: phase_template,
    journal_task_type: journal.journal_task_types.first,
    settings: [setting])
  }
  let(:journal_task_type) { journal.journal_task_types.first }

  it "creates a record" do
    post :create, params: { format: :json, task_template: { phase_template_id: phase_template.id,
                                                            journal_task_type_id: journal_task_type.id,
                                                            title: "Valid Title" } }
    expect(response.status).to eq(201)
  end

  it "updates a record" do
    put :update, params: { format: :json, id: task_template.id, task_template: { phase_template_id: phase_template.id,
                                                                                 journal_task_type_id: journal_task_type.id } }
    expect(response.status).to eq(204)
  end

  it "deletes a record" do
    delete :destroy, params: { format: :json, id: task_template.id }
    expect(response.status).to eq(204)
  end

  it "updates a setting" do
    put :update_setting, params: { format: :json, id: task_template.id, value: 'off', name: 'ithenticate_automation' }
    expect(response.status).to eq(204)
  end
end
