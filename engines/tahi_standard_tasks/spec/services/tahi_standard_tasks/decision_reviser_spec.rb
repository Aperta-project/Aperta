require 'rails_helper'

describe "TahiStandardTasks::DecisionReviser" do

  let(:task) { FactoryGirl.create(:register_decision_task, paper: paper) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator, :with_academic_editor)
  end
  let(:service) { TahiStandardTasks::DecisionReviser.new(task, double(:decision, verdict: "major_revision")) }

  describe "#process!" do

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

    describe "#process!" do
      describe "ReviseTask" do
        context "if one already exists" do
          let!(:revise_task) { FactoryGirl.create(:revise_task, paper: paper, completed: true) }

          it "marks it incomplete" do
            service.process!
            expect(revise_task.reload.completed?).to eq(false)
          end

          it "task has paper" do
            expect(revise_task.paper).to eq paper
          end

          it "task old_role is `author`" do
            expect(revise_task.old_role).to eq 'author'
          end
        end

        context "if one does not already exist" do
          subject { service.process! }
          let(:revise_task) { paper.tasks.find_by(type: "TahiStandardTasks::ReviseTask") }

          it "new one is created" do
            expect {
              subject
            }.to change(paper.tasks.where(type: "TahiStandardTasks::ReviseTask"), :count).by(1)
          end

          it "has academic editor and paper creator participants" do
            subject
            expect(revise_task.participants).to \
              match_array([paper.academic_editor, paper.creator])
          end

          it "task participants include the paper's author" do
            subject
            expect(revise_task.participants).to include(paper.creator)
          end

          it "task body includes the revise letter" do
            subject
            expect(revise_task.body.first.first['value']).to include task.major_revision_letter
          end
        end
      end
    end

  end
end
