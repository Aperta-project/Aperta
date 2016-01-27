require 'rails_helper'

describe TahiStandardTasks::Funder do
  describe "#paper" do
    let(:task) { FactoryGirl.create(:financial_disclosure_task) }
    let(:funder) { FactoryGirl.create(:funder, task: task) }

    it "always proxies to paper" do
      expect(funder.paper).to eq(task.paper)
    end
  end
end
