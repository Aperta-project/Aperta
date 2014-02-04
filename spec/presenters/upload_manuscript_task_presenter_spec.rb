require 'spec_helper'

describe UploadManuscriptTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let(:task) do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      task = UploadManuscriptTask.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first
      allow(task).to receive(:paper).and_return paper
      task
    end

    subject(:data_attributes) { UploadManuscriptTaskPresenter.new(task).data_attributes }

    it_behaves_like "all tasks, which have common attributes" do
      let(:card_name) { 'upload-manuscript' }
    end

    specify do
      expect(data_attributes).to include(
        'upload-paper-path' => upload_paper_path(task.paper, format: :json)
      )
    end
  end
end
