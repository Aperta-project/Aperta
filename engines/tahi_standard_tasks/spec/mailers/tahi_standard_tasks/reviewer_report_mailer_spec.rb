require 'rails_helper'

describe TahiStandardTasks::ReviewerReportMailer do
  describe ".notify_academic_editor_email" do
    let(:app_name) { 'TEST-APP-NAME' }

    let(:paper) do
      FactoryGirl.create(
        :paper,
        title: 'Studies on the effects of saying Abracadabra'
      )
    end

    let(:task) do
      FactoryGirl.create(
        :task,
        title: "Reviewer Report",
        old_role: 'reviewer',
        type: "TahiStandardTasks::ReviewerReportTask",
        paper: paper,
        completed: true
      )
    end

    let(:academic_editor) do
      FactoryGirl.create(
        :user,
        first_name: 'Andi',
        last_name: 'Plantenberg',
        email: 'andi@example.com'
      )
    end

    before do
      user = double(:user, last_name: 'Mazur')
      journal = double(:journal, name: 'PLOS Yeti')
      allow(paper).to receive(:creator).and_return(user)
      allow(paper).to receive(:academic_editors).and_return([academic_editor])
      allow(paper).to receive(:journal).and_return(journal)

      allow_any_instance_of(MailerHelper).to receive(:app_name).and_return app_name
      allow_any_instance_of(TemplateHelper).to receive(:app_name).and_return app_name
    end

    let(:email) do
      described_class.notify_academic_editor_email(
        task_id: task.id,
        recipient_id: academic_editor.id
      )
    end

    it "has correct subject line" do
      expect(email.subject).to eq "Reviewer has completed the review on #{app_name}"
    end

    it "sends to paper's editors" do
      expect(email.to).to eq(paper.academic_editors.map(&:email))
    end

    it "contains link to the task" do
      expect(email.body).to match(%r{\/papers\/#{paper.id}\/tasks\/#{task.id}})
    end

    it "contains the paper title" do
      expect(email.body).to match(/Studies on the effects of saying Abracadabra/)
    end

    it "greets the editor by name" do
      expect(email.body).to match(/Hello Andi Plantenberg/)
    end
  end
end
