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

  context "for Word doc upload" do
    let(:successful_response) do
      IhatJobResponse.new(state: 'completed',
                          outputs: [{
                            file_type: 'epub'
                          }],
                          options: {
                            recipe_name: 'docx_to_html',
                            metadata: {
                              paper_id: upload_task.paper.id,
                              user_id: user.id
                            }
                          })
    end
    let(:errored_response) do
      IhatJobResponse.new(state: 'errored',
                          outputs: [{
                            file_type: 'epub'
                          }],
                          options: {
                            recipe_nane: 'docx_to_html',
                            metadata: {
                              paper_id: upload_task.paper.id,
                              user_id: user.id
                            }
                          })
    end
    it 'sends a message on successful upload' do
      expect(pusher_channel).to receive_push(
        payload: hash_including(
                  message:  "Finished loading Word file. Any images that had been included in the manuscript should be uploaded directly to the figures card.",
                  messageType: 'success'),
        down: 'user', 
        on: 'flashMessage')
      described_class.call("tahi:paper:data_extracted", record: successful_response)
    end

    it 'sends a message on errored upload' do
      expect(pusher_channel).to receive_push(
        payload: hash_including(
                  message: "There was an error loading your Word file.",
                  messageType: 'error'),
        down: 'user',
        on: 'flashMessage')
      described_class.call("tahi:paper:data_extracted", record: errored_response)
    end
  end

  context "for Pdf document upload" do
    let(:successful_response) do
      IhatJobResponse.new(state: 'completed',
                          outputs: [{
                            file_type: 'epub'
                          }],
                          options: {
                            recipe_name: 'pdf_to_html',
                            metadata: {
                              paper_id: upload_task.paper.id,
                              user_id: user.id
                            }
                          })
    end
    let(:errored_response) do
      IhatJobResponse.new(state: 'errored',
                          outputs: [{
                            file_type: 'epub'
                          }],
                          options: {
                            recipe_name: 'pdf_to_html',
                            metadata: {
                              paper_id: upload_task.paper.id,
                              user_id: user.id
                            }
                          })
    end

    it 'sends a message on successful upload' do
      expect(pusher_channel).to receive_push(
        payload: hash_including(
                  message:  "Finished loading PDF file. Any images that had been included in the manuscript should be uploaded directly to the figures card.",
                  messageType: 'success'),
        down: 'user', 
        on: 'flashMessage')
      described_class.call("tahi:paper:data_extracted", record: successful_response)
    end

    it 'sends a message on errored upload' do
      expect(pusher_channel).to receive_push(
        payload: hash_including(
                  message: "There was an error loading your PDF file.",
                  messageType: 'error'),
        down: 'user',
        on: 'flashMessage')
      described_class.call("tahi:paper:data_extracted", record: errored_response)
    end
  end
end
