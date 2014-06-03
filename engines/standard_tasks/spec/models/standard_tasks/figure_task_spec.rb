require 'spec_helper'

describe StandardTasks::FigureTask do
  describe "defaults" do
    subject(:task) { StandardTasks::FigureTask.new }
    specify { expect(task.title).to eq 'Upload Figures' }
    specify { expect(task.role).to eq 'author' }
  end

  describe "#figure_access_details" do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }

    before :each do
      figures = [double(:figure, access_details: :hello)]
      allow(figure_task).to receive(:figures).and_return(figures)
    end

    let(:figure_task) do
      StandardTasks::FigureTask.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.phases.first
    end

    it "returns a JSON object of access details from figures" do
      expect(figure_task.figure_access_details).to eq [:hello]
    end
  end
end
