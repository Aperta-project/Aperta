require 'rails_helper'

describe "TahiStandardTasks::DecisionReviser" do

  let(:task) { FactoryGirl.create(:register_decision_task, paper: paper) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:service) { TahiStandardTasks::DecisionReviser.new(task) }

  describe "#process!" do

    describe "RegisterDecisionTask" do
      it "is marked incomplete" do
        task.update!(completed: true)
        service.process!
        expect(service.task.completed).to eq(false)
      end
    end

    describe "Paper" do
      it "is marked editable" do
        paper.update!(editable: false)
        service.process!
        expect(service.paper.editable).to eq(true)
      end

      it "adds a decision" do
        expect {
          service.process!
        }.to change(paper.decisions, :count).by(1)
      end
    end

    describe "ReviseTask" do
      context "if one already exists" do
        let!(:revise_task) { FactoryGirl.create(:revise_task, paper: paper, completed: true) }

        it "marks it incomplete" do
          service.process!
          expect(revise_task.reload.completed?).to eq(false)
        end
      end

      context "if does not already exist" do
        it "new one is created" do
          expect {
            service.process!
          }.to change(paper.tasks.where(type: "TahiStandardTasks::ReviseTask"), :count).by(1)
        end

        it "has participants of paper editor and paper creator" do
          FactoryGirl.create(:paper_role, :editor, paper: paper)
          service.process!
          revise_task = paper.tasks.find_by(type: "TahiStandardTasks::ReviseTask")
          expect(revise_task.participants).to match_array([ paper.editor, paper.creator ])
        end
      end
    end
  end
end
