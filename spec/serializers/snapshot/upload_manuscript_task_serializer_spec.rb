require "rails_helper"

describe Snapshot::UploadManuscriptTaskSerializer do
  let(:upload_manuscript_task) {FactoryGirl.create(:upload_manuscript_task)}

  it "serializes an upload manuscript task" do
    snapshot = Snapshot::UploadManuscriptTaskSerializer.new(upload_manuscript_task).snapshot

    expect(snapshot.count).to eq(0)
  end
end
