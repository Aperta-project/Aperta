require 'spec_helper'
describe TaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    it "returns a hash of data used to render an overlay" do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      task = UploadManuscriptTask.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first
      expect(TaskPresenter.new(task).data_attributes).to eq({
        'paper-title' => task.paper.title,
        'paper-path' => paper_path(task.paper),
        'paper-id' => task.paper.to_param,
        'task-path' => paper_task_path(task.paper, task),
        'card-name' => 'upload-manuscript'
      })
    end
  end
end
