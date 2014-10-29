require 'spec_helper'

describe StandardTasks::FigureTask do
  describe "#figure_access_details" do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }

    before :each do
      figures = [double(:figure, access_details: :hello)]
      paper = double(:paper, figures: figures)
      allow(figure_task).to receive(:paper).and_return(paper)
    end

    let(:figure_task) do
      StandardTasks::FigureTask.create!  completed: true,
        role: 'admin',
        title: "Upload Figures",
        phase: paper.phases.first
    end

    it "returns a JSON object of access details from figures" do
      expect(figure_task.figure_access_details).to eq [:hello]
    end
  end
end
