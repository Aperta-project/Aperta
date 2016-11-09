RSpec.shared_examples_for 'a reviewer report task' do |factory:|
  let(:paper) { create :paper, :submitted_lite }
  let(:task) { FactoryGirl.create(factory, paper: paper) }

  describe "#body" do
    context "when it has a custom value" do
      it "returns that value" do
        task.update! body: { hello: :world }
        expect(task.reload.body).to eq("hello" => "world")
      end
    end

    context "when it is set to a blank value" do
      it "returns an empty hash" do
        task.body = nil
        expect(task.body).to eq({})
      end
    end
  end

  describe '#create' do
    before do
      expect(task.paper.draft_decision).to be
    end

    it "belongs to the paper's latest decision" do
      task.save!

      expect(task.decision).to eq(task.paper.draft_decision)
      expect(task.reload.decision).to eq(task.paper.draft_decision)

      # find again to make sure everything is loaded from the DB without
      # any in-memory values sticking around
      refreshed_task = Task.find(task.id)
      expect(refreshed_task.decision).to eq(task.paper.draft_decision)
      expect(refreshed_task.reload.decision).to eq(task.paper.draft_decision)
    end
  end

  describe "#find_or_build_answer_for" do
    let(:decision) { FactoryGirl.create(:decision, paper: paper) }
    let(:nested_question) { FactoryGirl.create(:nested_question) }

    context "when there is no answer for the given question" do
      it "returns a new answer for the question and current decision" do
        answer = task.find_or_build_answer_for(
          nested_question: nested_question
        )
        expect(answer).to be_kind_of(NestedQuestionAnswer)
        expect(answer.new_record?).to be(true)
        expect(answer.owner).to eq(task)
        expect(answer.nested_question).to eq(nested_question)
        expect(answer.decision).to eq(task.decision)
      end
    end

    context "when there is an answer for the given question and current decision" do
      let!(:existing_answer) do
        FactoryGirl.create(
          :nested_question_answer,
          nested_question: nested_question,
          owner: task,
          decision: task.decision
        )
      end

      it "returns the existing answer" do
        answer = task.find_or_build_answer_for(nested_question: nested_question)
        expect(answer).to eq(existing_answer)
      end
    end
  end

  describe "#can_change?" do
    let!(:answer) { FactoryGirl.build(:nested_question_answer) }

    it "returns true when the task is not submitted" do
      task.update! body: { submitted: false }
      expect(task.can_change?(answer)).to be(true)
    end

    it "returns false when the task is submitted" do
      task.update! body: { submitted: true }
      expect(task.can_change?(answer)).to be(false)
    end
  end

  describe "#incomplete!" do
    before do
      task.update! body: { "submitted" => true }, completed: true
    end

    it "makes the task incomplete" do
      expect { task.incomplete! }.to change(task, :completed).to false
    end

    it "makes the task unsubmitted" do
      expect { task.incomplete! }.to change(task, :submitted?).to false
    end
  end

  describe "#submitted?" do
    it "returns true when it's submitted" do
      task.body = { "submitted" => true }
      expect(task.submitted?).to be(true)
    end

    it "returns false otherwise" do
      task.body = {}
      expect(task.submitted?).to be(false)
    end
  end
end
