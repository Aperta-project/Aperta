require "rails_helper"

describe Paper::DataExtracted::NotifyUser do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator)
  end
  let(:upload_task) do
    FactoryGirl.create(:upload_manuscript_task, paper: paper)
  end
  let(:successful_response) { IhatJobResponse.new(state: 'completed', options: { metadata: { paper_id: upload_task.paper.id } }) }
  let(:errored_response) { IhatJobResponse.new(state: 'errored', options: { metadata: { paper_id: upload_task.paper.id } }) }

  it 'sends a message on successful upload' do
    expect(pusher_channel).to receive_push(payload: hash_including(:message, messageType: 'success'), down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: successful_response)
  end

  it 'sends a message on errored upload' do
    expect(pusher_channel).to receive_push(payload: hash_including(:message, messageType: 'error'), down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: errored_response)
  end
end
