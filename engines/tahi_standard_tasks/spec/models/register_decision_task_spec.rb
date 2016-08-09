require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_academic_editor_role,
      :with_creator_role,
      :with_task_participant_role,
      name: "#{Faker::Company.profession} Studies"
    )
  end
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      :submitted_lite,
      journal: journal,
      title: Faker::Lorem.paragraph
    )
  end
  let!(:task) do
    TahiStandardTasks::RegisterDecisionTask.create!(
      title: "Register Decision",
      old_role: "editor",
      paper: paper,
      phase: paper.phases.first
    )
  end
  let(:decision) { paper.draft_decision }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end

  describe "save and retrieve paper decision and decision letter" do
    let(:paper) do
      FactoryGirl.create(
        :paper,
        :with_integration_journal,
        :with_creator,
        :with_tasks,
        title: "Crazy stubbing tests on rats",
        decision_letter: "Lorem Ipsum"
      )
    end

    let(:task) {
      TahiStandardTasks::RegisterDecisionTask.create(
        title: "Register Decision",
        old_role: "editor",
        phase: paper.phases.first)
    }

    before do
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#paper_decision_letter" do
      it "returns paper's decision" do
        expect(task.paper_decision_letter).to eq("Lorem Ipsum")
      end
    end

    describe "#paper_decision_letter=" do
      it "returns paper's decision" do
        task.paper_decision_letter = "Rejecting because I can"
        expect(task.paper_decision_letter).to eq("Rejecting because I can")
      end
    end
  end

  describe "#after_register" do
    context "decision is a revision" do
      before do
        allow(decision).to receive(:revision?).and_return(true)
      end

      it "invokes DecisionReviser" do
        expect(TahiStandardTasks::ReviseTask)
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
    let!(:decision_one) { FactoryGirl.create(:decision, :major_revision, paper: paper, major_version: 0, minor_version: 0) }
    let(:task) { FactoryGirl.create(:register_decision_task, paper: paper) }
    let(:subject_field) { double(value: Faker::Lorem.sentence) }
    let(:to_field) { double(value: Faker::Internet.safe_email) }

    before do
      expect(task).to receive(:answer_for).with('register_decision_questions--to-field').and_return(to_field)
      expect(task).to receive(:answer_for).with('register_decision_questions--subject-field').and_return(subject_field)
    end

    it "will email using last completed decision" do
      expect(TahiStandardTasks::RegisterDecisionMailer)
        .to receive_message_chain(:delay, :notify_author_email)
        .with(
          decision_id: decision_one,
          to_field: to_field.value,
          subject_field: subject_field.value)
      task.send_email
    end
  end
end
