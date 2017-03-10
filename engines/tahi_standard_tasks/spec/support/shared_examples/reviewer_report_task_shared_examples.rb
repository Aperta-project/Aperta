RSpec.shared_examples_for 'a reviewer report task' do |factory:|
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { create :paper, :submitted_lite, journal: journal }
  let(:task) { FactoryGirl.create(factory, paper: paper) }
  let(:body) { { "submitted" => false } }
  let!(:reviewer_user) do
    reviewer = FactoryGirl.create(:user)
    role = journal.create_reviewer_report_owner_role!
    reviewer.assign_to!(assigned_to: task, role: role)
    reviewer
  end

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

  describe "#can_change?" do
    let!(:answer) { FactoryGirl.build(:answer) }

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
    let(:task) do
      FactoryGirl.create(factory, paper: paper, title: "Review by Steve", completed: completed, body: body)
    end

    let(:result) do
      task.on_completion
      task.save!
      task.reload
    end

    context "the task is complete" do
      let(:completed) { true }
      context "the task's paper has its number_reviewer_reports flag set to true" do
        let(:paper) { create :paper, :submitted_lite, journal: journal, number_reviewer_reports: true }
        context "the task has a reviewer number" do
          let!(:reviewer_number) { FactoryGirl.create(:reviewer_number, user: reviewer_user, paper: paper, number: 2) }
          it "does not change the existing number" do
            expect(result.reviewer_number).to eq(2)
          end

          it "does not update the title" do
            expect(result.title).to eq("Review by Steve")
          end
        end
        context "the task does not have a reviewer number" do
          let(:body) { { "submitted" => false } }
          context "other numbered reviewers for the paper exist" do
            before do
              FactoryGirl.create(:reviewer_number, paper: paper, number: 1)
              FactoryGirl.create(:reviewer_number, paper: paper, number: 2)
            end

            it "sets the reviewer number to be one higher than the max of the other tasks" do
              expect(result.reviewer_number).to eq(3)
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
              expect(task.title).to eq("Review by Steve (#1)")
            end
          end
        end
      end
      context "the task's paper has its number_reviewer_reports flag set to false" do
        let(:paper) { create :paper, :submitted_lite, journal: journal, number_reviewer_reports: false }
        let(:body) { { "submitted" => false } }
        it "does not assign a number" do
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
      it "does not assign a number" do
        expect(result.reviewer_number).to eq(nil)
      end
      it "does not update the title" do
        expect(result.title).to eq("Review by Steve")
      end
    end
  end
end
