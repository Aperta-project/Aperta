require 'rails_helper'

describe TahiStandardTasks::InitialDecisionTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }
  let(:task) { FactoryGirl.create :initial_decision_task, paper: paper }

  describe '#initial_decision' do
    it 'gets initial decision' do
      expect(task.initial_decision).to eq(task.paper.decisions.last)
    end
  end

  describe '#paper_creation_hook' do
    it 'sets gradual_engagement attribute to true ' do
      expect(paper.gradual_engagement).to be_falsey
      task.paper_creation_hook(paper)
      expect(paper.reload.gradual_engagement).to be_truthy
    end
  end

  describe 'register' do
    let(:decision) { paper.decisions.latest }

    before do
      paper.update(publishing_state: :submitted)
      task.reload
    end

    context "when decision is not terminal" do
      before do
        allow(decision).to receive(:terminal?).and_return(false)
      end

      it "when builds a new decision" do
        expect { task.register decision }
          .to change { paper.reload.decisions.count }.by(1)
      end
    end

    context "when decision is terminal" do
      before do
        allow(decision).to receive(:terminal?).and_return(true)
      end

      it "builds a new decision" do
        expect { task.register decision }
          .not_to change { paper.reload.decisions.count }
      end
    end

    it "saves the decision to paper" do
      expect(task.paper).to receive(:make_decision).with(decision)
      task.register decision
    end

    it "sets the decision to be registered and initial" do
      task.register decision
      expect(decision.registered).to be(true)
      expect(decision.initial).to be(true)
    end

    it "sends an email to the author" do
      expect(TahiStandardTasks::InitialDecisionMailer)
        .to receive_message_chain(:delay, :notify)
        .with(decision_id: decision.id)
      task.register decision
    end
  end
end
