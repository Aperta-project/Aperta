require "rails_helper"

describe Snapshot::SupportingInformationTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
  let!(:supporting_info_file_1) do
    FactoryGirl.create(
      :supporting_information_file,
      owner: task,
      paper: paper,
      title: "supporting info 1 title",
      caption: "supporting info 1 caption",
      file: File.open(Rails.root.join("spec/fixtures/yeti.jpg"))
    )
  end
  let!(:supporting_info_file_2) do
    FactoryGirl.create(
      :supporting_information_file,
      owner: task,
      paper: paper,
      title: "supporting info 2 title",
      caption: "supporting info 2 caption",
      file: File.open(Rails.root.join("spec/fixtures/yeti.tiff"))
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
          { name: "file_hash", type: "text", value: supporting_info_file_1.file_hash },
          { name: "title", type: "text", value: "supporting info 1 title" },
          { name: "caption", type: "text", value: "supporting info 1 caption" },
          { name: "publishable", type: "boolean", value: true },
          { name: "striking_image", type: "boolean", value: false }
        ] },
        { name: "supporting-information-file", type: "properties", children: [
          { name: "id", type: "integer", value: supporting_info_file_2.id },
          { name: "file", type: "text", value: "yeti.tiff" },
          { name: "file_hash", type: "text", value: supporting_info_file_2.file_hash },
          { name: "title", type: "text", value: "supporting info 2 title" },
          { name: "caption", type: "text", value: "supporting info 2 caption" },
          { name: "publishable", type: "boolean", value: true },
          { name: "striking_image", type: "boolean", value: false }
        ] }
      )
    end

    context "serializing related nested questions" do
      include_examples "snapshot serializes related nested questions", resource: :task
    end
  end
end
