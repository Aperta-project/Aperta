require 'rails_helper'

describe TahiStandardTasks::Funder do
  let(:task) { FactoryGirl.create(:financial_disclosure_task) }
  let(:funder) { FactoryGirl.create(:funder, task: task) }

  describe "#paper" do
    it "always proxies to paper" do
      expect(funder.paper).to eq(task.paper)
    end
  end

  describe "#funding_statement" do
    let(:funder) do
      FactoryGirl.create(:funder,
                         task: task,
                         name: 'Something Foundation',
                         grant_number: '00-3324-23498')
    end
    it "includes funder name" do
      expect(funder.funding_statement).to include(funder.name)
    end

    it "includes funder's grant number" do
      expect(funder.funding_statement).to include(funder.grant_number)
    end
  end
end
