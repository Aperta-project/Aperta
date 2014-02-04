require 'spec_helper'

describe FigureTaskPresenter do
  include Rails.application.routes.url_helpers

  describe "#data_attributes" do
    let(:task) do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      allow(paper).to receive(:figures).and_return [
        double(:figure, access_details: { one: 1 }),
        double(:figure, access_details: { two: 2 })
      ]
      task = FigureTask.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.task_manager.phases.first
      allow(task).to receive(:paper).and_return paper
      task
    end

    subject(:data_attributes) { FigureTaskPresenter.new(task).data_attributes }

    it "includes standard task data" do
      expect(data_attributes).to include 'card-name' => 'figure'
    end

    it "includes custom figure data" do
      expect(data_attributes).to include(
        'figures' => '[{"one":1},{"two":2}]',
        'figures-path' => paper_figures_path(task.paper)
      )
    end
  end
end
