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
        expect(answer.decision).to eq(paper.draft_decision)
      end
    end

    context "when there is an answer for the given question and current decision" do
      let!(:existing_answer) do
        FactoryGirl.create(
          :nested_question_answer,
          nested_question: nested_question,
          owner: task,
          decision: task.paper.draft_decision
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

  describe "#on_completion" do
    let(:task) { FactoryGirl.create(factory, paper: paper, title: "Review by Steve", completed: completed, body: body) }
    let(:result) do
      task.on_completion
      task.save!
      task.reload
    end
    context "the task is complete" do
      let(:completed) { true }
      context "the task's paper has its number_reviewer_reports flag set to true" do
        let(:paper) { create :paper, :submitted_lite, number_reviewer_reports: true }
        context "the task has a reviewer number" do
          let(:body) { { "reviewer_number" => 2 } }
          it "does not change the existing number" do
            expect(result.body).to eq(body)
            expect(result.reviewer_number).to eq(2)
          end

          it "does not update the title" do
            expect(result.title).to eq("Review by Steve")
          end
        end
        context "the task does not have a reviewer number" do
          let(:body) { { "submitted" => false } }
          context "other reviewer report task subclasses for the paper exist" do
            before do
              FactoryGirl.create(factory, paper: paper, completed: false)
              FactoryGirl.create(factory, paper: paper, completed: true, body: { "reviewer_number" => 1 })
              FactoryGirl.create(:front_matter_reviewer_report_task, paper: paper, completed: false, body: { "reviewer_number" => 2 })
            end

            it "sets the reviewer number to be one higher than the max of the other tasks" do
              expect(result.reviewer_number).to eq(3)
              expect(task.body).to eq("reviewer_number" => 3, "submitted" => false)
            end

            it "appends the reviewer number to the task title" do
              expect(result.title).to eq("Review by Steve (#3)")
            end
          end
          context "it's the only completed reviewer report task for the paper" do
            before do
              FactoryGirl.create(factory, paper: paper, completed: false)
            end
            it "sets the reviewer number to be one 1" do
              expect(result.reviewer_number).to eq(1)
              expect(task.body).to eq("reviewer_number" => 1, "submitted" => false)
              expect(task.title).to eq("Review by Steve (#1)")
            end
          end
        end
      end
      context "the task's paper has its number_reviewer_reports flag set to false" do
        let(:paper) { create :paper, :submitted_lite, number_reviewer_reports: false }
        let(:body) { { "submitted" => false } }
        it "does not assign a number" do
          expect(result.body).to eq(body)
          expect(result.reviewer_number).to eq(nil)
        end
      end
    end
    context "the task is not complete" do
      let(:completed) { false }
      let(:body) { { "submitted" => false } }
      it "does not change the task body" do
        expect(result.body).to eq(body)
      end
      it "does not update the title" do
        expect(result.title).to eq("Review by Steve")
      end
    end
  end
end
