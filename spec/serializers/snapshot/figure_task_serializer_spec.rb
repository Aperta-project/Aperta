require "rails_helper"

describe Snapshot::FigureTaskSerializer do
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
    snapshot = Snapshot::FigureTaskSerializer.new(task).snapshot
    figure = snapshot[0]

    expect(figure[:title]).to eq(attachment.title)
    expect(figure[:caption]).to eq(attachment.caption)
  end
end
