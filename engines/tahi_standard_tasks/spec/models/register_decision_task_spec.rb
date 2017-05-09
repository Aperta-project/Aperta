require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  subject(:task) do
    FactoryGirl.create(
      :register_decision_task,
      :with_stubbed_associations,
      paper: paper
    )
  end
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :with_creator,
      :submitted_lite,
      title: Faker::Lorem.paragraph
    )
  end
  let(:decision) { paper.draft_decision }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#after_register" do
    context "decision is a revision" do
      before do
        allow(decision).to receive(:revision?).and_return(true)
      end

      it "calls #setup_new_revision with proper arguments" do
        expect(TahiStandardTasks::ReviseTask)
          .to receive(:setup_new_revision).with(task.paper, task.phase)
        expect(TahiStandardTasks::UploadManuscriptTask)
          .to receive(:setup_new_revision).with(task.paper, task.phase)
        task.after_register decision
      end

      it "marks the task complete" do
        expect(task).to receive(:complete!)
        task.after_register decision
      end
    end
  end

  describe "#send_email" do
    let!(:decision_one) do
      FactoryGirl.create(
        :decision,
        :major_revision,
        paper: paper,
        major_version: 0,
        minor_version: 0
      )
    end
    let(:subject_field) { double(value: Faker::Lorem.sentence) }
    let(:to_field) { double(value: Faker::Internet.safe_email) }

    before do
      expect(task).to receive(:answer_for)
        .with('register_decision_questions--to-field')
        .and_return to_field

      expect(task).to receive(:answer_for)
        .with('register_decision_questions--subject-field')
        .and_return subject_field
    end

    it "will email using last completed decision" do
      expect(TahiStandardTasks::RegisterDecisionMailer)
        .to receive_message_chain(:delay, :notify_author_email)
        .with(
          decision_id: decision_one.id,
          to_field: to_field.value,
          subject_field: subject_field.value
        )
      task.send_email
    end
  end
end
