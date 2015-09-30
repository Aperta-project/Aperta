require "rails_helper"

describe Snapshot::BaseTaskSerializer do
  describe "serializing nested questions" do
    def make_nested_questions(task)
      nested_questions = FactoryGirl.create_list(:nested_question, 3)
      nested_questions.each do |nested_question|
        nested_question.owner_id = task.id
      end
      nested_questions[0].text = "First question"
      nested_questions[1].text = "Second question"
      nested_questions[2].text = "Third question"
      nested_questions
    end

    it "has questions without answers" do
      task = FactoryGirl.create(:task)
      nested_questions = make_nested_questions(task)
      allow_any_instance_of(Task).to receive(:nested_questions).and_return(nested_questions)


      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot


      expect(snapshot[:properties]).to be_nil
      expect(snapshot[:questions].count).to eq(3)
    end

    it "serializes children" do
      task = FactoryGirl.create(:task)
      nested_questions = make_nested_questions(task)
      nested_child = FactoryGirl.create(:nested_question)
      nested_child.owner_id = task.id
      nested_questions[1].children << nested_child
      nested_child.parent_id = nested_questions[1].id

      allow_any_instance_of(Task).to receive(:nested_questions).and_return(nested_questions)
      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot
      binding.pry

      expect(snapshot[:questions].count).to eq(3)
      expect(snapshot[:questions][1][:children].count).to eq(1)
    end

    it "has questions with answers" do
      task = FactoryGirl.create(:task)
      nested_questions = make_nested_questions(task)
      nested_question_answers = []
      nested_question_answer = FactoryGirl.create(:nested_question_answer)
      nested_question_answer.owner_id = task.id
      nested_question_answer.owner_type = "task"
      nested_question_answer.nested_question_id = nested_questions.first.id
      nested_question_answers << nested_question_answer

      allow_any_instance_of(Task).to receive(:nested_questions).and_return(nested_questions)
      allow_any_instance_of(Task).to receive(:nested_question_answers).and_return(nested_question_answers)
      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      binding.pry
    end


    it "doesn't matter what order questions are answered in"

  end
end
