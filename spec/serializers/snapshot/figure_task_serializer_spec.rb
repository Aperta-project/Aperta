require "rails_helper"

describe Snapshot::FigureTaskSerializer do
  def find_property properties, name
    properties.select { |p| p[:name] == name }.first[:value]
  end

  let(:task) { FactoryGirl.create(:figure_task) }
  let(:figure) { FactoryGirl.create(:figure) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:attachment) { FactoryGirl.create(:attachment, :with_task)}

  before do
    figure.title = "figure title"
    figure.caption = "figure caption"
    paper.figures << figure
    task.paper = paper
  end

  it "snapshots a figure task" do
    snapshot = Snapshot::FigureTaskSerializer.new(task).as_json
    figure = snapshot[0][:children][0][:children]

    expect(find_property(figure, "title")).to eq("figure title")
    expect(find_property(figure, "caption")).to eq("figure caption")
  end
end
