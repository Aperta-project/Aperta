require 'rails_helper'

describe Phase do
  it "defines a DEFAULT_PHASE_NAME" do
    expect(Phase.const_defined? :DEFAULT_PHASE_NAMES).to be_truthy
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

  describe ".tasks_by_position" do
    let(:phase) { FactoryGirl.create(:phase)}

    context "with no tasks" do
      specify { expect(phase.tasks_by_position).to be_empty }
    end

    context "with a single task" do
      let(:tasks) { [FactoryGirl.create(:task, phase: phase)] }

      specify { expect(phase.tasks_by_position).to eq(tasks) }
    end

    context "with many tasks" do
      let(:tasks) { FactoryGirl.create_list(:task, 5, phase: phase) }

      # pretend the tasks are re-sorted in reverse
      before { phase.update!(task_positions: tasks.map(&:id).reverse) }

      it "tasks order match the order they appear in task_positions" do
        expect(phase.tasks.order(id: :asc)).to eq(tasks)
        expect(phase.tasks_by_position).to eq(tasks.reverse)
      end
    end

  end

end
