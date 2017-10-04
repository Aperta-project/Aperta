require 'rails_helper'

describe TahiStandardTasks::UploadManuscriptTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end

describe "sourcefile validation for a completed task" do
  let(:paper) { FactoryGirl.build(:paper) }
  let(:task) do
    FactoryGirl.build(
      :upload_manuscript_task,
      completed: true,
      paper: paper
    )
  end

  let(:sourcefile_errors) do
    task.valid?
    task.errors[:sourcefile]
  end

  describe "needs source file" do
    context "the paper's file type is not pdf" do
      before do
        allow(paper).to receive(:file_type).and_return('docx')
      end
      it "has no ready issues even with a blank sourcefile" do
        allow(paper).to receive(:sourcefile?).and_return(false)
        expect(sourcefile_errors).to be_empty
      end
    end

    context "the paper's file type is pdf" do
      before do
        allow(paper).to receive(:file_type).and_return('pdf')
      end

      context "the paper is in revision" do
        before do
          allow(paper).to receive(:in_revision?).and_return(true)
        end

        it "is not ready if the sourcefile is blank" do
          allow(paper).to receive(:sourcefile?).and_return(false)
          expect(sourcefile_errors).to contain_exactly 'Please upload your source file'
        end

        it "is ready if the sourcefile is present" do
          allow(paper).to receive(:sourcefile?).and_return(true)
          expect(sourcefile_errors).to be_empty
        end
      end

      context "the paper has a major version" do
        before do
          allow(paper).to receive(:in_revision?).and_return(false)
          allow(paper).to receive(:major_version).and_return(1)
        end

        it "is not ready if the sourcefile is blank" do
          allow(paper).to receive(:sourcefile?).and_return(false)
          expect(sourcefile_errors).to contain_exactly 'Please upload your source file'
        end

        it "is ready if the sourcefile is present" do
          allow(paper).to receive(:sourcefile?).and_return(true)
          expect(sourcefile_errors).to be_empty
        end
      end

      context "does not require a source file if the paper is not in revision or has no major version" do
        it "has no ready issues even with a blank sourcefile" do
          allow(paper).to receive(:in_revision?).and_return(false)
          allow(paper).to receive(:major_version).and_return(0)
          allow(paper).to receive(:sourcefile?).and_return(false)
          expect(sourcefile_errors).to be_empty
        end

        it "will not blow up if the paper's major_version is nil" do
          allow(paper).to receive(:in_revision?).and_return(false)
          allow(paper).to receive(:major_version).and_return(nil)
          allow(paper).to receive(:sourcefile?).and_return(false)
          expect(sourcefile_errors).to be_empty
        end
      end
    end
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

  context "with an existing upload manuscript task" do
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

  context "with no existing upload manuscript task" do
    context "a Card corresponding to the TahiStandardTasks::UploadManuscriptTask CardTaskType exists with a published version" do
      let(:card_task_type) { FactoryGirl.create(:card_task_type, task_class: 'TahiStandardTasks::UploadManuscriptTask') }
      let(:existing_card) { FactoryGirl.create(:card, :versioned, card_task_type: card_task_type) }
      let(:published_version) { existing_card.latest_published_card_version }
      it "creates a new upload manuscript task with that CardVersion" do
        expect(TaskFactory)
          .to receive(:create).with(subject, paper: paper, phase: phase, card_version: published_version)

        subject.setup_new_revision paper, phase
      end
    end

    context "the card does not exist or a published version does not exit" do
      it "does not create a new task" do
        expect(TaskFactory).to_not receive(:create)

        subject.setup_new_revision paper, phase
      end
    end
  end
end
