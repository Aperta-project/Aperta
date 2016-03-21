require 'rails_helper'

describe TahiStandardTasks::Funder do
  let(:task) { FactoryGirl.create(:financial_disclosure_task) }
  let(:funder) { FactoryGirl.create(:funder, task: task) }
  let(:comment_only_funder) do
    TahiStandardTasks::Funder.new(additional_comments: 'Im da bes')
  end

  describe "#paper" do
    it "always proxies to paper" do
      expect(funder.paper).to eq(task.paper)
    end
  end

  describe "#funding_statement" do
    let(:funder) do
      FactoryGirl.build(:funder,
                        task: task,
                        name: 'Something Foundation',
                        grant_number: '00-3324-23498',
                        additional_comments: 'Darmok and Jalad')
    end
    it "includes funder name" do
      expect(funder.funding_statement).to include(funder.name)
    end

    it "includes funder's grant number" do
      expect(funder.funding_statement).to include(funder.grant_number)
    end

    it "includes funder's additional comments" do
      expect(funder.funding_statement).to include(funder.additional_comments)
    end

    it "only includes the comment if that's all that's provided" do
      expected = "#{comment_only_funder.additional_comments}."
      expect(comment_only_funder.funding_statement).to eq expected
    end
  end

  describe "#only_has_additional_comments" do
    it "is false when nothing is set on the model" do
      funder = TahiStandardTasks::Funder.new
      expect(funder.send(:only_has_additional_comments?)).to be false
    end

    it "is true when only additional_comments is set" do
      funder = TahiStandardTasks::Funder.new(\
        additional_comments: 'whatever bro')
      expect(funder.send(:only_has_additional_comments?)).to be true
    end

    it "is false when additional_comments and anything else is set" do
      funder = TahiStandardTasks::Funder.new(\
        additional_comments: 'whatever bro', name: 'Dobis')
      expect(funder.send(:only_has_additional_comments?)).to be false
    end
  end
end
