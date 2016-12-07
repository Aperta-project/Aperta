require "rails_helper"

describe Paper::DataExtracted::NotifyUser do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_creator)
  end
  let(:upload_task) do
    FactoryGirl.create(:upload_manuscript_task, paper: paper)
  end
  let(:user) { paper.creator }
  let(:successful_response) do
    IhatJobResponse.new(state: 'completed',
                        outputs: [{
                          file_type: 'docx'
                        }],
                        options: {
                          metadata: {
                            paper_id: upload_task.paper.id,
                            user_id: user.id
                          }
                        })
  end
  let(:errored_response) do
    IhatJobResponse.new(state: 'errored',
                        outputs: [{
                          file_type: 'docx'
                        }],
                        options: {
                          metadata: {
                            paper_id: upload_task.paper.id,
                            user_id: user.id
                          }
                        })
  end

  it 'sends a message on successful upload' do
    expect(pusher_channel).to receive_push(payload: hash_including(:message, messageType: 'success'), down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: successful_response)
  end

  it 'sends a message on errored upload' do
    expect(pusher_channel).to receive_push(payload: hash_including(:message, messageType: 'error'), down: 'user', on: 'flashMessage')
    described_class.call("tahi:paper:data_extracted", record: errored_response)
  end
end
