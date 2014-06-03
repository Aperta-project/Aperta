require 'spec_helper'

describe StandardTasks::AttachmentUploader do
  describe "#store_dir" do
    it "includes the paper id in the path" do
      paper = FactoryGirl.create(:paper, :with_tasks)
      FactoryGirl.create(:task, phase: paper.phases.first, type: "StandardTasks::FigureTask")
      figure_task = StandardTasks::FigureTask.first
      figure = figure_task.figures.create!
      uploader = StandardTasks::AttachmentUploader.new(figure, :attachment)
      expect(uploader.store_dir).to eq "uploads/paper/#{paper.id}/figure/attachment/#{figure.id}"
    end
  end
end
