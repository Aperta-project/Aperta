require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_academic_editor_role,
      :with_creator_role,
      :with_task_participant_role,
      name: 'PLOS Yeti'
    )
  end
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      journal: journal,
      title: 'Crazy stubbing tests on rats'
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

    let(:decision) {
      paper.decisions.first
    }

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

  describe "#complete_decision" do
    before do
      allow_any_instance_of(Decision).to receive(:revision?).and_return(true)
      task.paper.decisions.latest.update_attribute(:verdict, 'major_revision')

      paper.update(publishing_state: :submitted)
      task.reload
    end

    it "invokes DecisionReviser" do
      expect_any_instance_of(TahiStandardTasks::DecisionReviser).to receive(:process!)
      task.complete_decision
    end
  end

  describe "#after_update" do
    before do
      allow_any_instance_of(Decision).to receive(:revision?).and_return(true)
      task.paper.decisions.latest.update_attribute(:verdict, 'major_revision')
    end

    context "when the decision is 'Major Revision' and task is incomplete" do
      it "does not create a new task for the paper" do
        expect {
          task.save!
        }.to_not change { task.paper.tasks.size }
      end
    end

    context "when the decision is 'Major Revision' and task is completed" do
      let(:revise_task) do
        task.paper.tasks.detect do |paper_task|
          paper_task.type == "TahiStandardTasks::ReviseTask"
        end
      end

      before do
        task.save!
        task.update_attributes completed: true
        task.after_update
      end

      it "task has no participants" do
        expect(task.participants).to be_empty
      end

      it "task participants does not include author" do
        expect(task.participants).to_not include paper.creator
      end
    end

    describe "#send_email" do
      let(:task) { FactoryGirl.create(:register_decision_task, paper: paper) }
      let!(:decision_one) { FactoryGirl.create(:decision, :major_revision, paper: paper) }
      let!(:decision_pending) { FactoryGirl.create(:decision, :pending, paper: paper) }

      it "will email using latest non-pending decision" do
        expect(TahiStandardTasks::RegisterDecisionMailer).to receive_message_chain(:delay, :notify_author_email).with(decision_id: decision_one)
        task.send_email
      end
    end

    describe "#complete_decision" do
      let(:decision) { paper.decisions.first }

      before do
        allow(task).to receive(:paper).and_return(paper)
        allow(paper).to receive(:make_decision)
        allow_any_instance_of(Decision).to receive(:revision?).and_return(true)
      end

      it "saves the decision to paper" do
        expect(paper).to receive(:make_decision).with(decision)
        task.complete_decision
      end

      it "prepares a new revise task" do
        paper.update(publishing_state: "submitted")

        task_type = TahiStandardTasks::ReviseTask.name
        expect {
          task.complete_decision
        }.to change { paper.tasks.where(type: task_type).count }.by(1)
      end
    end
  end
end
