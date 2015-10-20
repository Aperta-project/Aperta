require "rails_helper"

describe Snapshot::SupportingInformationTaskSerializer do
  it "serializes a supporting information task" do
    task = FactoryGirl.create(:supporting_information_task)
    snapshot = Snapshot::SupportingInformationTaskSerializer.new(task).snapshot

    expect(snapshot.count).to eq(0)
  end

  it "serializes files if they are present" do
    paper = FactoryGirl.create(:paper, :with_tasks)
    supporting_information_task = ::TahiStandardTasks::SupportingInformationTask.create!(completed: true,
      phase: paper.phases.first,
      title: "Supporting Info",
      role: "author")
    allow(supporting_information_task).to receive(:paper).and_return(paper)

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

    expect(snapshot[0][:children][0][:children][1][:value]).to eq(file1.title)
    expect(snapshot[0][:children][1][:name]).to eq("publishable")
    expect(snapshot[0][:children][2][:name]).to eq("status")
    expect(snapshot[1][:children][0][:children][1][:value]).to eq(file2.title)
    expect(snapshot[1][:children][1][:name]).to eq("publishable")
    expect(snapshot[1][:children][2][:name]).to eq("status")
  end
end
