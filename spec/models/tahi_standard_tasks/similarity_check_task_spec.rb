require 'rails_helper'

describe TahiStandardTasks::SimilarityCheckTask do
  describe "after_paper_submitted" do
    it "calls AutomatedSimilarityCheck.new with itself and the paper, then runs it" do
      task = FactoryGirl.create(:similarity_check_task)
      paper = task.paper
      dbl = double("check")
      expect(AutomatedSimilarityCheck).to receive(:new).with(task, paper).and_return dbl
      expect(dbl).to receive(:run)
      task.after_paper_submitted(paper)
    end
  end
end
