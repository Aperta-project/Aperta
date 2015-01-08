require 'spec_helper'

describe StandardTasks::ReviewerReportTask do
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, title: "Crazy stubbing tests on rats"
  end

  let(:task) {
    StandardTasks::ReviewerReportTask.create!(title: "Reviewer Report",
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
        allow(StandardTasks::ReviewerReportMailer).to receive_message_chain("delay.notify_editor_email") { true }
        task.completed = true
        task.save!
        expect(task.send_emails).to eq([editor])
      end
    end

    context "if the task is updated but not completed" do
      it "does not send emails" do
        StandardTasks::ReviewerReportMailer = double(:reviewer_report_mailer)
        task.completed = false # or any other update
        task.save!
        expect(task.send_emails).to eq(nil)
      end
    end
  end
end
