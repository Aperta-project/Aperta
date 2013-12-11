require 'spec_helper'

describe TaskManager do
  describe "associations" do
    describe "phases" do
      let(:task_manager) do
        TaskManager.create! phases: [
          Phase.new(name: 'Todo'),
          Phase.new(name: 'Doing')
        ]
      end

      it "returns in order for consistency" do
        old_phases = task_manager.phases
        task_manager.phases.first.name = "frozen yoghurt"
        task_manager.phases.first.save!
        expect(task_manager.reload.phases).to eq(old_phases)
      end

    end
  end

  describe "initialization" do
    describe "phases" do
      it "initializes default phases" do
        default_phases = [
          Phase.new(name: 'name 1'),
          Phase.new(name: 'name 2'),
          Phase.new(name: 'name 3')
        ]
        allow(Phase).to receive(:default_phases).and_return(default_phases)

        task_manager = TaskManager.new
        expect(task_manager.phases).to match_array default_phases
      end

      context "when phases are specified" do
        it "uses provided phases" do
          phases = [Phase.new(name: 'Doing')]

          task_manager = TaskManager.new phases: phases
          expect(task_manager.phases).to match_array phases
        end
      end
    end
  end
end
