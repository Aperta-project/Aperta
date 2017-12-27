require 'rails_helper'

describe TahiStandardTasks::SendToApexTask do
  let!(:paper) do
    FactoryGirl.create(:paper, :with_tasks, publishing_state: 'accepted')
  end
  let!(:task) do
    FactoryGirl.create(:send_to_apex_task, :with_loaded_card, paper: paper)
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#export_deliveries association' do
    let!(:task) do
      FactoryGirl.create(:send_to_apex_task, :with_loaded_card, export_deliveries: [export_delivery])
    end
    let!(:export_delivery) { FactoryGirl.build(:export_delivery, paper: paper, destination: 'apex') }

    it 'destroys export deliveries when the task is destroyed' do
      expect do
        task.destroy
      end.to change { task.export_deliveries.count }.by(-1)

      expect { export_delivery.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
