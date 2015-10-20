require "spec_helper"

describe Paper::DataExtracted::NotifyUser do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:upload_task) { FactoryGirl.create(:upload_manuscript_task) }
  let(:successful_response) { IhatJobResponse.new(state: 'completed', options: { metadata: { paper_id: upload_task.paper.id } }) }
  let(:errored_response) { IhatJobResponse.new(state: 'errored', options: { metadata: { paper_id: upload_task.paper.id } }) }

  it 'sends a message on successful upload' do
    expect(pusher_channel).to receive_push(serialize: [:messageType, :message], down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: successful_response)
  end

  it 'sends a message on errored upload' do
    expect(pusher_channel).to receive_push(serialize: [:messageType, :message], down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: errored_response)
  end
end
