require 'rails_helper'

describe TahiStandardTasks::ReviewerReportTask do
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, title: "Crazy stubbing tests on rats"
  end

  let(:task) {
    TahiStandardTasks::ReviewerReportTask.create!(title: "Reviewer Report",
                                              role: "reviewer",
                                              phase: paper.phases.first,
                                              completed: false)
  }

  let(:editor) {
    double(:editor,
           full_name: 'Andi Plantenberg',
           email: "andi+example@example.com",
           id: 1)
  }

  before do
    user = double(:user, last_name: 'Mazur')
    journal = double(:journal, name: 'PLOS Yeti')
    allow(paper).to receive(:creator).and_return(user)
    allow(paper).to receive(:editors).and_return([editor])
    allow(paper).to receive(:journal).and_return(journal)
    allow(task).to receive(:paper).and_return(paper)
  end

  describe "#send_emails" do
    context "if the task transitions to completed" do
      it "sends emails to the paper's editors" do
        allow(TahiStandardTasks::ReviewerReportMailer).to receive_message_chain("delay.notify_editor_email") { true }
        task.completed = true
        task.save!
        expect(task.send_emails).to eq([editor])
      end
    end

    context "if the task is updated but not completed" do
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

  describe "#can_change?" do
    let!(:question) { Question.create! task: task, ident: "hello", answer: "I shouldn't change" }

    it "doesn't let update questions" do
      task.update! body: { submitted: true }
      question.update answer: "Changed"
      expect(question.reload.answer).to eq("I shouldn't change")
    end
  end
end
