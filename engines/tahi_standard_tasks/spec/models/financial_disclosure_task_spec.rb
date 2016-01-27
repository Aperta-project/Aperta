require 'rails_helper'

describe TahiStandardTasks::FinancialDisclosureTask do
  describe '#funders association' do
    let!(:task) do
      FactoryGirl.create(:financial_disclosure_task, funders: [funder])
    end
    let!(:funder) { FactoryGirl.create(:funder) }

    it 'detroys funders when the task is destroyed' do
      expect do
        task.destroy
      end.to change { task.funders.count }.by(-1)

      expect { funder.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
