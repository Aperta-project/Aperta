require "rails_helper"

describe Snapshot::SupportingInformationTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
  let(:supporting_info_file_1) do
    FactoryGirl.create(
      :supporting_information_file,
      title: "supporting info 1 title",
      caption: "supporting info 1 caption",
      attachment: File.open(Rails.root.join("spec/fixtures/yeti.jpg"))
    )
  end
  let(:supporting_info_file_2) do
    FactoryGirl.create(
      :supporting_information_file,
      title: "supporting info 2 title",
      caption: "supporting info 2 caption",
      attachment: File.open(Rails.root.join("spec/fixtures/yeti.tiff"))
    )
  end
  let(:paper) do
    FactoryGirl.create(
      :paper,
      supporting_information_files: [
        supporting_info_file_1,
        supporting_info_file_2
      ]
    )
  end

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "supporting-information-task",
        type: "properties"
      )
    end

    it "serializes the supporting information files for the task's paper" do
      expect(serializer.as_json[:children]).to include(
        { name: "supporting-information-file", type: "properties", children: [
          { name: "id", type: "integer", value: supporting_info_file_1.id },
          { name: "file", type: "text", value: "yeti.jpg" },
          { name: "title", type: "text", value: "supporting info 1 title" },
          { name: "caption", type: "text", value: "supporting info 1 caption" },
          { name: "publishable", type: "boolean", value: true }
        ] },
        { name: "supporting-information-file", type: "properties", children: [
          { name: "id", type: "integer", value: supporting_info_file_2.id },
          { name: "file", type: "text", value: "yeti.tiff" },
          { name: "title", type: "text", value: "supporting info 2 title" },
          { name: "caption", type: "text", value: "supporting info 2 caption" },
          { name: "publishable", type: "boolean", value: true }
        ] }
      )
    end

    context "serializing related nested questions" do
      include_examples "snapshot serializes related nested questions", resource: :task
    end
  end
end
