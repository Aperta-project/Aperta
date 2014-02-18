require 'spec_helper'

describe PaperEditorTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let :assignee do
      User.create! username: 'worker',
        first_name: 'Busy', last_name: 'Bee',
        password: 'password', password_confirmation: 'password',
        email: 'worker@example.org'
    end

    let :editor do
      User.create! username: 'editor',
        first_name: 'Ernie', last_name: 'Editor',
        password: 'password', password_confirmation: 'password',
        email: 'editor@example.org'
    end

    let(:task) do
      author = User.create! username: 'adam',
                            password: 'password', password_confirmation: 'password',
                            email: 'adam@example.org'
      paper = Paper.create! title: "Foo bar",
        short_title: "Foo",
        journal: Journal.create!,
        user: author
      task = PaperEditorTask.create! completed: true,
        phase: paper.task_manager.phases.first,
        assignee: assignee
      allow(task).to receive(:paper).and_return paper
      allow(task).to receive(:assignees).and_return [assignee]
      allow(task).to receive(:editor_id).and_return editor.id
      allow(task).to receive(:editors).and_return [editor]
      task
    end

    subject(:data_attributes) { PaperEditorTaskPresenter.new(task).data_attributes }

    it_behaves_like "all tasks, which have common attributes" do
      let(:card_name) { 'paper-editor' }
      let(:assignee_id) { assignee.id }
      let(:assignees) { [[assignee.id, assignee.full_name]] }
    end

    it "returns custom data for paper editor task" do
      expect(data_attributes).to include({
        'editorId' => editor.id,
        'editors'  => [[editor.id, editor.full_name]]
      })
    end
  end
end
