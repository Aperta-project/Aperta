require 'rails_helper'

describe TahiStandardTasks::RegisterDecisionTask do
  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks, title: "Crazy stubbing tests on rats"
  end
  let!(:task) { TahiStandardTasks::RegisterDecisionTask.create!(title: "Register Decision", role: "editor", phase: paper.phases.first) }

  context "letters" do
    before do
      user = double(:last_name, last_name: 'Mazur')
      editor = double(:full_name, full_name: 'Andi Plantenberg')
      journal = double(:name, name: 'PLOS Yeti')
      allow(paper).to receive(:creator).and_return(user)
      allow(paper).to receive(:editors).and_return([editor])
      allow(paper).to receive(:journal).and_return(journal)
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#accept_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.accept_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.accept_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.accept_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.accept_letter).to match(/Crazy stubbing tests on rats/)
      end
    end

    describe "#revise_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.revise_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.revise_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.revise_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.revise_letter).to match(/Crazy stubbing tests on rats/)
      end
    end

    describe "#reject_letter" do
      it "returns the letter with the author's name filled in" do
        expect(task.reject_letter).to match(/Mazur/)
      end

      it "returns the letter with the editor's name filled in" do
        expect(task.reject_letter).to match(/Andi Plantenberg/)
      end

      it "returns the letter with journal name filled in" do
        expect(task.reject_letter).to match(/PLOS Yeti/)
      end

      it "returns the letter with paper title filled in" do
        expect(task.reject_letter).to match(/Crazy stubbing tests on rats/)
      end
    end

    context "when the editor hasn't been assigned yet" do
      it "returns 'Editor not assigned'" do
        allow(paper).to receive(:editors).and_return([])
        expect(task.accept_letter).to match(/Editor not assigned/)
        expect(task.accept_letter).to_not match(/Andi Plantenberg/)
      end
    end
  end

  describe "save and retrieve paper decision and decision letter" do
    let(:paper) {
      FactoryGirl.create(:paper, :with_tasks,
        title: "Crazy stubbing tests on rats",
        decision: "Accepted",
        decision_letter: "Lorem Ipsum")
    }

    let(:task) {
      TahiStandardTasks::RegisterDecisionTask.create(
        title: "Register Decision",
        role: "editor",
        phase: paper.phases.first)
    }

    before do
      allow(task).to receive(:paper).and_return(paper)
    end

    describe "#paper_decision" do
      it "returns paper's decision" do
        expect(task.paper_decision).to eq("Accepted")
      end
    end

    describe "#paper_decision=" do
      it "returns paper's decision" do
        task.paper_decision = "Rejected"
        expect(task.paper_decision).to eq("Rejected")
      end
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

    describe "#send_email" do
      context "if the task transitions to completed" do
        it "sends emails to the paper's author" do
          allow(TahiStandardTasks::RegisterDecisionMailer).to receive_message_chain("delay.notify_author_email") { true }
          task.completed = true
          task.save!
          expect(task.send_email).to eq true
        end
      end
    end
  end

  describe "#after_update" do
    before do
      allow_any_instance_of(TahiStandardTasks::RegisterDecisionTask).to receive(:revise_decision?).and_return(true)
    end

    context "when the decision is 'revise' and task is incomplete" do
      it "does not create a new task for the paper" do
        expect {
          task.paper.decision = 'revise'
          task.save!
        }.to_not change { task.paper.tasks.size }
      end
    end

    context "when the decision is 'revise' and task is completed" do
      let(:please_revise_task) do
        task.paper.tasks.detect do |paper_task|
          paper_task.type == "TahiStandardTasks::ReviseTask"
        end
      end

      before do
        task.paper.decision = 'revise'
        task.save!
        task.update_attributes completed: true
        task.after_update
      end

      it "paper revise event is broadcasted" do
        event_subscriber = :not_called
        event_payload = []
        TahiNotifier.subscribe 'paper.revised' do |_, payload|
          event_subscriber = :called
          event_payload = payload
        end

        task.after_update
        expect(event_subscriber).to eq :called
        expect(event_payload[:paper_id]).to eq(paper.id)
      end

      it "task is not nil" do
        expect(please_revise_task).to_not be_nil
      end

      it "task has paper" do
        expect(please_revise_task.paper).to eq paper
      end

      it "task role is `author`" do
        expect(please_revise_task.role).to eq 'author'
      end

      it "task participants include the paper's author" do
        expect(please_revise_task.participants).to eq [paper.creator]
      end

      it "task body includes the revise letter" do
        expect(please_revise_task.body.first.first['value']).to include task.revise_letter
      end
    end
  end
end
