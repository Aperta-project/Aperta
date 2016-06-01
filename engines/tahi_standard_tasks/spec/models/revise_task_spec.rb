require 'rails_helper'

describe TahiStandardTasks::ReviseTask do
  describe "#setup_new_revision" do
    let!(:paper) do
      FactoryGirl.create(
        :paper_with_phases,
        editable: false,
        phases_count: 3
      )
    end

    let(:phase) { paper.phases[1] }
    subject(:subject) { TahiStandardTasks::ReviseTask }

    it "sets the paper's editable flag to true" do
      subject.setup_new_revision paper, phase
      expect(paper.editable).to be(true)
    end

    it "creates a new decision for the paper" do
      expect { subject.setup_new_revision paper, phase }
        .to change { Decision.count }.by(1)
    end

    context "with an existing revise task" do
      let!(:task) do
        FactoryGirl.create(
          :revise_task,
          completed: true,
          paper: paper
        )
      end

      it "uncompletes the task" do
        subject.setup_new_revision paper, phase
        expect(task.reload.completed).to be(false)
      end

      it "updates the task's phase"do
        subject.setup_new_revision paper, phase
        expect(task.reload.phase_id).to be(phase.id)
      end
    end

    context "with no existing revise task" do
      it "creates a new revise task" do
        expect(TaskFactory)
          .to receive(:create).with(
            subject,
            paper: paper,
            phase: phase
          )

        subject.setup_new_revision paper, phase
      end
    end
  end
end
