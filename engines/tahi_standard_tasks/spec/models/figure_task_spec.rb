require 'rails_helper'

describe TahiStandardTasks::FigureTask do
  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end

  describe "#figure_access_details" do
    let(:paper) { FactoryGirl.create(:paper) }
    let!(:task) { FactoryGirl.create(:figure_task, paper: paper) }

    before :each do
      figures = [double(:figure, access_details: :hello)]
      paper = double(:paper, figures: figures)
      allow(task).to receive(:paper).and_return(paper)
    end

    it "returns a JSON object of access details from figures" do
      expect(task.figure_access_details).to eq [:hello]
    end
  end
end
