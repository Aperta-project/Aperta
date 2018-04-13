# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
          message:  'Finished loading Word file. Any figures included in the file will have been removed ' \
                    'and should now be uploaded directly by ' \
                    'clicking \'Figures\'.',
          messageType: 'success'
        ),
        down: 'user',
        on: 'flashMessage'
      )
      described_class.call("tahi:paper:data_extracted", record: successful_response)
    end

    it 'sends a message on errored upload' do
      expect(pusher_channel).to receive_push(
        payload: hash_including(
          message: "There was an error loading your Word file.",
          messageType: 'error'
        ),
        down: 'user',
        on: 'flashMessage'
      )
      described_class.call("tahi:paper:data_extracted", record: errored_response)
    end
  end

end
