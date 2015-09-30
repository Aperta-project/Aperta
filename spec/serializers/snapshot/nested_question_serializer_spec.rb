require "rails_helper"

describe Snapshot::BaseTaskSerializer do
  let(:task) { FactoryGirl.create(:task) }

  describe "serializing nested questions" do
    before do
      nested_questions = make_nested_questions(task)
      allow_any_instance_of(Task).to receive(:nested_questions).and_return(nested_questions)
    end

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

    def make_nested_question_answer(nested_question_id, value)
      nested_question_answer = FactoryGirl.create(:nested_question_answer)
      nested_question_answer.owner_id = task.id
      nested_question_answer.owner_type = "task"
      nested_question_answer.value = value
      nested_question_answer.nested_question_id = nested_question_id
      nested_question_answer
    end

    it "has questions without answers" do
      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      expect(snapshot[:properties]).to be_nil
      expect(snapshot[:questions].count).to eq(3)
    end

    it "serializes children" do
      nested_child = FactoryGirl.create(:nested_question)
      nested_child.owner_id = task.id
      task.nested_questions[1].children << nested_child
      nested_child.parent_id = task.nested_questions[1].id

      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      expect(snapshot[:questions].count).to eq(3)
      expect(snapshot[:questions][1][:children].count).to eq(1)
    end

    it "has questions with answers" do
      nested_question_answers = []
      nested_question_answer = make_nested_question_answer(task.nested_questions.first.id, "Answer Value")
      nested_question_answers << nested_question_answer
      allow_any_instance_of(Task).to receive(:nested_question_answers).and_return(nested_question_answers)

      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      expect(snapshot[:questions][0][:answers].count).to eq(1)
      expect(snapshot[:questions][0][:answers][0][:value]).to eq("Answer Value")
      expect(snapshot[:questions][1][:answers].count).to eq(0)
      expect(snapshot[:questions][2][:answers].count).to eq(0)
    end

    it "doesn't matter what order questions are answered in" do
      nested_question_answers = []
      nested_question_answer = make_nested_question_answer(task.nested_questions[2].id, "Last Value")
      nested_question_answers << nested_question_answer
      nested_question_answer = make_nested_question_answer(task.nested_questions[0].id, "First Value")
      nested_question_answers << nested_question_answer
      allow_any_instance_of(Task).to receive(:nested_question_answers).and_return(nested_question_answers)

      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      expect(snapshot[:questions][0][:answers].count).to eq(1)
      expect(snapshot[:questions][0][:answers][0][:value]).to eq("First Value")
      expect(snapshot[:questions][1][:answers].count).to eq(0)
      expect(snapshot[:questions][2][:answers].count).to eq(1)
      expect(snapshot[:questions][2][:answers][0][:value]).to eq("Last Value")
    end

    it "serializes attachments" do
      nested_question_answers = []
      nested_question_answer = FactoryGirl.create(:nested_question_answer)
      attachment = FactoryGirl.create(:question_attachment, :with_fake_attachment)
      attachment.question_id = nested_question_answer.id
      attachment.save!
      nested_question_answer.owner_id = task.id
      nested_question_answer.owner_type = "task"
      nested_question_answer.value = "text that is different"
      nested_question_answer.nested_question_id = task.nested_questions.first.id
      nested_question_answers << nested_question_answer
      allow_any_instance_of(Task).to receive(:nested_question_answers).and_return(nested_question_answers)

      snapshot = Snapshot::BaseTaskSerializer.new(task).snapshot

      expect(snapshot[:questions][0][:answers][0][:attachment][:file]).to eq(attachment[:attachment])
      expect(snapshot[:questions][0][:answers][0][:value]).to eq("text that is different")
    end
  end
end
