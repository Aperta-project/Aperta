require "rails_helper"

describe Snapshot::FigureTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:figure_task, paper: paper) }
  let(:figure_1) do
    FactoryGirl.create(
      :figure,
      title: "figure 1 title",
      caption: "figure 1 caption",
      file: File.open(Rails.root.join("spec/fixtures/yeti.jpg"))
    )
  end
  let(:figure_2) do
    FactoryGirl.create(
      :figure,
      title: "figure 2 title",
      caption: "figure 2 caption",
      file: File.open(Rails.root.join("spec/fixtures/yeti.tiff"))
    )
  end

  let(:paper) { FactoryGirl.create(:paper, figures: [figure_1, figure_2]) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "figure-task",
        type: "properties"
      )
    end

    it "serializes the figures for the task's paper" do
      expect(serializer.as_json[:children]).to include(
        { name: "figure", type: "properties", children: [
          { name: "id", type: "integer", value: figure_1.id },
          { name: "file", type: "text", value: "yeti.jpg" },
          { name: "file_hash", type: "text", value: figure_1.file_hash },
          { name: "title", type: "text", value: "figure 1 title" },
          { name: "striking_image", type: "boolean", value: false }
        ]},
        { name: "figure", type: "properties", children: [
          { name: "id", type: "integer", value: figure_2.id },
          { name: "file", type: "text", value: "yeti.tiff" },
          { name: "file_hash", type: "text", value: figure_2.file_hash },
          { name: "title", type: "text", value: "figure 2 title" },
          { name: "striking_image", type: "boolean", value: false }
        ]}
      )
    end

    context "serializing related nested questions" do
      include_examples "snapshot serializes related nested questions", resource: :task
    end
  end
end
