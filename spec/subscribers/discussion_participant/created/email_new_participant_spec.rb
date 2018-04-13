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

require 'rails_helper'

describe DiscussionParticipant::Created::EmailNewParticipant do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:participant) { FactoryGirl.create(:discussion_participant) }
  let!(:current_user) { FactoryGirl.create(:user) }

  it 'sends an email to people added to discussions' do
    expect(mailer).to receive(:notify_added_to_topic).with(
        participant.user_id,
        current_user.id,
        participant.discussion_topic_id
    )
    described_class.call(
      'tahi:discussion_participant:created',
      record: participant,
      current_user_id: current_user.id
    )
  end

  context 'the new participant is the current user' do
    let!(:participant) { FactoryGirl.create(:discussion_participant, user: current_user) }

    it 'does not send an email' do
      expect(mailer).to_not receive(:notify_added_to_topic)
      described_class.call(
        'tahi:discussion_participant:created',
        record: participant,
        current_user_id: current_user.id
      )
    end
  end
end
