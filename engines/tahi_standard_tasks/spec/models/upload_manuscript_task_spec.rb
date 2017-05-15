require 'rails_helper'

describe TahiStandardTasks::UploadManuscriptTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end

describe "#setup_new_revision" do
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      editable: false,
      phases_count: 3
    )
  end

  let(:phase) { paper.phases[1] }
  subject(:subject) { TahiStandardTasks::UploadManuscriptTask }

  context "with an existing revise task" do
    let!(:task) do
      FactoryGirl.create(
        :upload_manuscript_task,
        completed: true,
        paper: paper
      )
    end

    it "uncompletes the task" do
      subject.setup_new_revision paper, phase
      expect(task.reload.completed).to be(false)
    end

    it "updates the task's phase" do
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
