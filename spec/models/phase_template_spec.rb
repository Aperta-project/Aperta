require 'rails_helper'

describe PhaseTemplate do

  let(:mmt) { FactoryGirl.create(:manuscript_manager_template) }
  let(:phase_template) {
    FactoryGirl.create(:phase_template, manuscript_manager_template: mmt)
}
  let!(:task_template) {
    FactoryGirl.create(:task_template,
      phase_template: phase_template)
    }

  describe "#destroy" do
    it "also destroy TaskTemplate" do
      phase_tempate_id = phase_template.id
      phase_template.destroy

      expect(TaskTemplate.where(phase_template_id: phase_tempate_id).count).to eq 0
    end
  end
end
