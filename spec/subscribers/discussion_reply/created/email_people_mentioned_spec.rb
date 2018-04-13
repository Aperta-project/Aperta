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

describe DiscussionReply::Created::EmailPeopleMentioned do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:mention1) { FactoryGirl.create(:user) }
  let(:mention2) { FactoryGirl.create(:user) }
  let(:body) { "Interesting point @#{mention1.username} and @#{mention2.username}" }
  let(:reply) { FactoryGirl.create(:discussion_reply, body: body) }
  let(:discussion_topic) { reply.discussion_topic }

  before :each do
    allow_any_instance_of(User).to receive(:can?).and_return(true)
  end

  context 'a reply with one at-mention' do
    let(:body) { "Interesting point @#{mention1.username}" }

    it 'sends an email to a person @mentioned in the discussion' do
      expect(mailer).to receive(:notify_mention_in_discussion)
        .with(mention1.id, reply.discussion_topic_id, reply.id)

      described_class.call('tahi:discussion_reply:created',
                           record: reply)
    end
  end

  context 'a reply with two at-mentions' do
    let(:body) { "Interesting point @#{mention1.username} and @#{mention2.username}" }

    it 'sends an email to all people @mentioned in the discussion' do
      expect(mailer).to receive(:notify_mention_in_discussion)
        .with(mention1.id, reply.discussion_topic_id, reply.id)
      expect(mailer).to receive(:notify_mention_in_discussion)
        .with(mention2.id, reply.discussion_topic_id, reply.id)

      described_class.call('tahi:discussion_reply:created',
                           record: reply)
    end

    context 'the poster in one of the at-mentions' do
      let(:reply) { FactoryGirl.create(:discussion_reply, body: body, replier: mention2) }

      it 'does not send an email to the poster' do
        expect(mailer).to receive(:notify_mention_in_discussion)
          .with(mention1.id, reply.discussion_topic_id, reply.id)
        expect(mailer).to_not receive(:notify_mention_in_discussion)
          .with(mention2.id, reply.discussion_topic_id, reply.id)

        described_class.call('tahi:discussion_reply:created',
                             record: reply)
      end
    end
  end
end
