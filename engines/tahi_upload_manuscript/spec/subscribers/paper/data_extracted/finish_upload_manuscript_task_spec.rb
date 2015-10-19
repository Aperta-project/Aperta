require 'rails_helper'

describe Paper::DataExtracted::FinishUploadManuscriptTask do
  include EventStreamMatchers

  let(:upload_task) { FactoryGirl.create(:upload_manuscript_task) }
  let(:response) { IhatJobResponse.new(state: 'pending', options: { metadata: { paper_id: upload_task.paper.id } }) }

  it "marks the upload manuscript task as completed" do
    expect(upload_task).to_not be_completed
    described_class.call("tahi:paper:data_extracted", record: response)
    expect(upload_task.reload).to be_completed
  end
end
