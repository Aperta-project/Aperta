require 'rails_helper'

describe TahiStandardTasks::SendToApexTask do
  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks
  end
  let!(:task) do
    FactoryGirl.create(:send_to_apex_task, :with_loaded_card, paper: paper)
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#apex_deliveries association' do
    let!(:task) do
      FactoryGirl.create(:send_to_apex_task, :with_loaded_card, apex_deliveries: [apex_delivery])
    end
    let!(:apex_delivery) { FactoryGirl.create(:apex_delivery) }

    it 'detroys apex deliveries when the task is destroyed' do
      expect do
        task.destroy
      end.to change { task.apex_deliveries.count }.by(-1)

      expect { apex_delivery.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#send_to_apex' do
    # It triggers the job to build the zip file and FTP it to APEX
    pending
  end
end
