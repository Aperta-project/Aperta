require 'spec_helper'

describe Phase do
  it "defines a DEFAULT_PHASE_NAME" do
    expect(Phase.const_defined? :DEFAULT_PHASE_NAMES).to be_truthy
  end

  describe "#insert_at_position" do
    context "A task manager with phases" do
      let!(:task_manager) { TaskManager.create! } # this will create 5 phases
      let(:new_pos) { 0 }
      let(:new_params) { {task_manager_id: task_manager.id, name: "New phase", position: new_pos} }

      let(:insert) { Phase.insert_at_position new_params }

      it "returns a persisted phase with the given parameters" do
        result = insert
        expect(result.reload.position).to eq(new_pos)
        expect(result.persisted?).to eq(true)
      end

      describe "reordering existing phases" do
        let(:new_pos) { 2 }
        it "increments the positions of existing phases with positions >= the new phase's position" do
          p2 = Phase.where(position: 2).first
          p3 = Phase.where(position: 3).first
          result = insert
          expect(p2.reload.position).to eq(3)
          expect(p3.reload.position).to eq(4)
        end
        it "doesn't move phases whose positions are less than the new phase" do
          existing_phase = Phase.where(position: 1).first
          insert
          expect(existing_phase.reload.position).to eq(1)
        end
      end
    end
  end

  describe ".default_phases" do
    before do
      stub_const "Phase::DEFAULT_PHASE_NAMES", %w(Todo Doing Done)
    end

    subject(:phases) { Phase.default_phases }

    it "returns an array of phase instances for each phase name" do
      expect(phases.size).to eq(3)
      expect(phases[0].name).to eq "Todo"
      expect(phases[1].name).to eq "Doing"
      expect(phases[2].name).to eq "Done"
    end

    it "does not persist any of the phases" do
      expect(phases.all? &:new_record?).to be true
    end
  end

  describe "initialization" do
    describe "tasks" do
      describe "Submission Data phase" do
        let(:phase) { Phase.new name: 'Submission Data' }

        it "initializes one declaration task" do
          expect(phase.tasks.map(&:class)).to include(DeclarationTask)
        end

        it "initializes one figures task" do
          expect(phase.tasks.map(&:class)).to include(StandardTasks::FigureTask)
        end

        it "initializes one authors task" do
          expect(phase.tasks.map(&:class)).to include(StandardTasks::AuthorsTask)
        end

        it "initializes one upload manuscript task" do
          expect(phase.tasks.map(&:class)).to include(UploadManuscriptTask)
        end
      end

      describe "Assign Editor phase" do
        let(:phase) { Phase.new name: 'Assign Editor' }

        it "initializes one paper admin task" do
          expect(phase.tasks.map(&:class)).to include(PaperAdminTask)
        end

        it "initializes one tech check task" do
          expect(phase.tasks.map(&:class)).to include(StandardTasks::TechCheckTask)
        end

        it "initializes one paper editor task" do
          expect(phase.tasks.map(&:class)).to include(PaperEditorTask)
        end
      end

      describe "Assign Reviewers phase" do
        let(:phase) { Phase.new name: 'Assign Reviewers' }

        it "initializes one assign reviewer task" do
          expect(phase.tasks.map(&:class)).to include(PaperReviewerTask)
        end
      end

      describe "Make Decision phase" do
        let(:phase) { Phase.new name: 'Make Decision' }

        it "initializes one register decision task" do
          expect(phase.tasks.map(&:class)).to include(RegisterDecisionTask)
        end
      end

      context "when the phase is not one of the default phases" do
        specify { expect(Phase.new.tasks).to be_empty }
      end

      context "when tasks are specified" do
        it "uses provided task" do
          tasks = [Task.new]
          phase = Phase.new name: 'Assign Editor', tasks: tasks
          expect(phase.tasks).to eq tasks
        end
      end
    end
  end
end
