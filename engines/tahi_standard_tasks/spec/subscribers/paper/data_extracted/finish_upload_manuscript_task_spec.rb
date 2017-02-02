require 'rails_helper'

describe Paper::DataExtracted::FinishUploadManuscriptTask do
  include EventStreamMatchers

  let(:upload_task) { FactoryGirl.create(:upload_manuscript_task) }
  let(:response_completed) { IhatJobResponse.new(state: 'completed', options: { metadata: { paper_id: upload_task.paper.id } }) }
  let(:response_errored) { IhatJobResponse.new(state: 'errored', options: { metadata: { paper_id: upload_task.paper.id } }) }
  let(:file) { FactoryGirl.create(:manuscript_attachment) }

  it "marks the upload manuscript task as completed if job is completed" do
    expect(upload_task).to_not be_completed
    described_class.call("tahi:paper:data_extracted", record: response_completed)
    expect(upload_task.reload).to be_completed
  end

  it "does not mark the upload manuscript task as completed if job is errored" do
    expect(upload_task).to_not be_completed
    described_class.call("tahi:paper:data_extracted", record: response_errored)
    expect(upload_task.reload).to_not be_completed
  end

  it "marks the upload manuscript task complete if the file type is docx" do
    expect(upload_task).to_not be_completed
    file.file_type = 'docx'
    upload_task.paper.file = file
    described_class.call("tahi:paper:data_extracted:finish_upload_manuscript_task", record: response_completed)
    expect(upload_task.reload).to be_completed
  end

  it "does not mark the upload manuscript task complete if the file type is pdf" do
    expect(upload_task).to_not be_completed
    file.file_type = 'pdf'
    upload_task.paper.file = file
    described_class.call("tahi:paper:data_extracted:finish_upload_manuscript_task", record: response_completed)
    expect(upload_task.reload).to_not be_completed
  end
end
