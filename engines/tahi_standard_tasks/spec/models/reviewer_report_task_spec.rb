require 'rails_helper'

describe TahiStandardTasks::ReviewerReportTask do
  let(:task) { FactoryGirl.create(:reviewer_report_task) }
  let(:paper) { task.paper }

  describe "#send_emails" do
    let(:editors){ [ FactoryGirl.create(:user) ]}

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

    context "when it is not set" do
      it "returns an empty hash" do
        expect(task.body).to eq({})
      end
    end
  end

  describe "#decision" do
    let(:paper) { FactoryGirl.create :paper, :with_tasks }
    let(:task) {
      TahiStandardTasks::ReviewerReportTask.create!(title: "Reviewer Report",
                                                role: "reviewer",
                                                phase: paper.phases.first,
                                                completed: false)
    }
    let(:previous_decision) { paper.decisions[1] }
    let(:latest_decision) { paper.decisions[0] }

    before do
      paper.decisions <<  FactoryGirl.create(:decision, paper_id: task.paper.id)

      # make sure we are starting off with at least two decisions
      expect(paper.decisions.length).to be(2)
    end

    context "when both the paper and the task are not submitted" do
      before do
        task.paper.update! publishing_state: "unsubmitted"
        task.incomplete!

        expect(paper.submitted?).to be(false)
        expect(task.submitted?).to be(false)
      end

      it "returns the latest decision" do
        expect(task.decision).to eq(latest_decision)
      end
    end

    context "when the paper is not submitted, but the task is" do
      before do
        paper.update! publishing_state: "in_revision"
        task.update! body: task.body.merge("submitted" => true)

        expect(paper.submitted?).to be(false)
        expect(task.submitted?).to be(true)
      end

      it "returns the penultimate decision" do
        expect(task.decision).to eq(previous_decision)
      end
    end

    context "when the paper is submitted, but the task isn't" do
      before do
        paper.update! publishing_state: "submitted"
        task.update! body: task.body.except("submitted")
        task.reload

        expect(paper.submitted?).to be(true)
        expect(task.submitted?).to be(false)
      end

      it "returns the latest decision" do
        expect(task.decision).to eq(latest_decision)
      end
    end

    context "when both the paper and the task are submitted" do
      before do
        paper.update! publishing_state: "submitted"
        task.update! body: {"submitted" => true}
        task.paper.reload

        expect(paper.submitted?).to be(true)
        expect(task.submitted?).to be(true)
      end

      it "returns the latest decision" do
        expect(task.decision).to eq(latest_decision)
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
      task.update! body: {"submitted" => true}, completed: true
    end

    it "makes the task incomplete" do
      expect{
        task.incomplete!
      }.to change(task, :completed).to false
    end

    it "makes the task unsubmitted" do
      expect{
        task.incomplete!
      }.to change(task, :submitted?).to false
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
