require 'rails_helper'

describe TahiStandardTasks::ReviewerReportTask do
  let(:task) { FactoryGirl.create(:reviewer_report_task) }
  let(:paper) { task.paper }

  describe "#send_emails" do
    let(:editors) { [FactoryGirl.create(:user)] }

    before do
      # make sure we have editors for sending emails to
      allow(paper).to receive(:editors).and_return editors
    end

    context "when the task transitions to completed" do
      it "sends emails to the paper's editors" do
        allow(TahiStandardTasks::ReviewerReportMailer).to receive_message_chain("delay.notify_editor_email") { true }
        task.completed = true
        task.save!
        expect(task.send_emails).to eq(paper.editors)
      end
    end

    context "when the task is updated but not completed" do
      it "does not send emails" do
        TahiStandardTasks::ReviewerReportMailer = double(:reviewer_report_mailer)
        task.completed = false # or any other update
        task.save!
        expect(task.send_emails).to eq(nil)
      end
    end
  end

  describe "#body" do
    context "when it has a custom value" do
      it "returns that value" do
        task.update! body: { hello: :world }
        expect(task.reload.body).to eq("hello" => "world")
      end
    end

    context "when it is set to a blank value" do
      it "returns an empty hash" do
        task.body = nil
        expect(task.body).to eq({})
      end
    end
  end

  describe '#create' do
    let(:task) { FactoryGirl.build(:reviewer_report_task) }

    it "belongs to the paper's latest decision" do
      task.save!
      expect(task.decision).to eq(task.paper.decisions.latest)
      expect(task.reload.decision).to eq(task.paper.decisions.latest)
    end
  end

  describe "#decision" do
    let(:decision) { FactoryGirl.create(:decision, paper: paper) }

    it "returns the current decision" do
      task.decision = decision
      task.save!
      expect(task.decision).to eq(decision)
    end

    context "when there is no decision set" do
      it "returns nil" do
        task.decision = nil
        task.save!
        expect(task.decision).to be(nil)
      end
    end
  end

  describe "#can_change?" do
    let!(:question) { Question.create! task: task, ident: "hello", answer: "I shouldn't change" }

    it "doesn't let update questions" do
      task.update! body: { submitted: true }
      question.update answer: "Changed"
      expect(question.reload.answer).to eq("I shouldn't change")
    end
  end

  describe "#incomplete!" do
    before do
      task.update! body: { "submitted" => true }, completed: true
    end

    it "makes the task incomplete" do
      expect { task.incomplete! }.to change(task, :completed).to false
    end

    it "makes the task unsubmitted" do
      expect { task.incomplete! }.to change(task, :submitted?).to false
    end
  end

  describe "#submitted?" do
    it "returns true when it's submitted" do
      task.body = { "submitted" => true }
      expect(task.submitted?).to be(true)
    end

    it "returns false otherwise" do
      task.body = {}
      expect(task.submitted?).to be(false)
    end
  end
end
