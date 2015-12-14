require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks
  end
  let!(:task) do
    TahiStandardTasks::SendToApexTask.create!(
      role: 'editor',
      phase: paper.phases.first)
  end

  describe '#send_to_apex' do
    # It triggers the job to build the zip file and FTP it to APEX
    pending
  end
end
