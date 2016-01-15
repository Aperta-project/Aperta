require 'rails_helper'

describe QuestionAttachment do
  let(:paper) { FactoryGirl.create(:paper_with_phases) }
  let(:question_attachment) do
    task = FactoryGirl.build(:task, paper: paper)
    answer = FactoryGirl.build(:nested_question_answer, owner: task)
    FactoryGirl.create(:question_attachment, nested_question_answer: answer)
  end

  describe "#paper" do
    it "returns the question's paper" do
      expect(question_attachment.paper).to eq(paper)
    end
  end
end
