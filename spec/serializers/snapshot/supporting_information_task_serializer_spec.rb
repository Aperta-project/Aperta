require "rails_helper"

describe Snapshot::SupportingInformationTaskSerializer do
  let(:paper) { FactoryGirl.create(:paper, :with_tasks) }

  before :each do
    files = [double(:file, access_details: :hello)]
    paper = double(:paper, files: files, to_i: 1)
    allow(supporting_information_task).to receive(:paper).and_return(paper)
  end

  let(:supporting_information_task) do
    ::TahiStandardTasks::SupportingInformationTask.create! completed: true,
      phase: paper.phases.first,
      title: "Supporting Info",
      role: "author"
  end

  it "serializes a supporting information task" do
    task = FactoryGirl.create(:supporting_information_task)
    snapshot = Snapshot::SupportingInformationTaskSerializer.new(task).snapshot

    expect(snapshot.count).to eq(0)
  end

  it "serializes files if they are present" do
    file1 = FactoryGirl.create(:supporting_information_file)
    file2 = FactoryGirl.create(:supporting_information_file)
    file1.attachment = "file1.eps"
    file1.title = "file 1 title"
    file1.caption = "file 1 caption"
    file2.attachment = "file2.pdf"
    file2.title = "file 2 title"
    file2.caption = "file 2 caption"
    paper.supporting_information_files << file1
    paper.supporting_information_files << file2

    snapshot = Snapshot::SupportingInformationTaskSerializer.new(supporting_information_task).snapshot
    binding.pry

  end
end
