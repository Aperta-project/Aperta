require 'rails_helper'

describe PhaseTemplatesController do
  let(:user) { create :user, :site_admin }
  before { sign_in user }

  let(:mmt) { FactoryGirl.create(:manuscript_manager_template) }
  let(:phase_template) { FactoryGirl.create(:phase_template, manuscript_manager_template: mmt) }

  expect_policy_enforcement

  it "creates a record" do
    post :create, format: :json, phase_template: { name: "A Phase", manuscript_manager_template_id: mmt.id, position: 0 }
    expect(response.status).to eq(201)
    response_json = JSON.parse(response.body, symbolize_names: true)
    expect(PhaseTemplate.find(response_json[:phase_template][:id])).to_not be_nil
  end

  it "updates a record" do
    put :update, format: :json, id: phase_template.id, phase_template: { name: "Phase Transition", manuscript_manager_template_id: mmt.id, position: 0 }
    expect(response.status).to eq(204)
  end

  it "deletes a record" do
    delete :destroy, format: :json, id: phase_template.id
    expect(response.status).to eq(204)
  end
end

