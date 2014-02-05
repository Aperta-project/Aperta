require 'spec_helper'

describe PaperAdminTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let :assignee do
      User.create! username: 'worker',
        first_name: 'Busy', last_name: 'Bee',
        password: 'password', password_confirmation: 'password',
        email: 'worker@example.org'
    end

    let(:task) do
      author = User.create! username: 'adam',
                            password: 'password', password_confirmation: 'password',
                            email: 'adam@example.org'
      paper = Paper.create! title: "Foo bar",
        short_title: "Foo",
        journal: Journal.create!,
        user: author
      task = PaperAdminTask.create! completed: true,
        phase: paper.task_manager.phases.first,
        assignee: assignee
      allow(task).to receive(:paper).and_return paper
      allow(task).to receive(:assignees).and_return [assignee]
      task
    end

    subject(:data_attributes) { PaperAdminTaskPresenter.new(task).data_attributes }

    it_behaves_like "all tasks, which have common attributes" do
      let(:card_name) { 'paper-admin' }
      let(:assignees) { '[]' }
      let(:assignee_id) { nil }
    end

    it "returns custom data for paper admin task" do
      expect(data_attributes).to include({
        'admin-id' => task.assignee_id,
        'admins'   => [[assignee.id, assignee.full_name]].to_json
      })
    end
  end
end
