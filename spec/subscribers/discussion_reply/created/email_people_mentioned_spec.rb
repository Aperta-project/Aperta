require 'rails_helper'

describe DiscussionReply::Created::EmailPeopleMentioned do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:mention1) { FactoryGirl.create(:user) }
  let(:mention2) { FactoryGirl.create(:user) }

  it 'sends an email to a person @mentioned in the discussion' do
    body = "Interesting point @#{mention1.username}"
    reply = FactoryGirl.create(:discussion_reply, body: body)
    expect(mailer).to receive(:notify_mention_in_discussion)
      .with(mention1.id, reply.discussion_topic_id, reply.id)

    described_class.call('tahi:discussion_reply:created',
                         record: reply)
  end

  it 'sends an email to all people @mentioned in the discussion' do
    body = "Interesting point @#{mention1.username} and @#{mention2.username}"
    reply = FactoryGirl.create(:discussion_reply, body: body)
    expect(mailer).to receive(:notify_mention_in_discussion)
      .with(mention1.id, reply.discussion_topic_id, reply.id)
    expect(mailer).to receive(:notify_mention_in_discussion)
      .with(mention2.id, reply.discussion_topic_id, reply.id)

    described_class.call('tahi:discussion_reply:created',
                         record: reply)
  end

  it 'does not send an email to the poster' do
    body = "Interesting point @#{mention1.username} and @#{mention2.username}"
    reply = FactoryGirl.create(:discussion_reply, body: body, replier: mention2)
    expect(mailer).to receive(:notify_mention_in_discussion)
      .with(mention1.id, reply.discussion_topic_id, reply.id)
    expect(mailer).to_not receive(:notify_mention_in_discussion)
      .with(mention2.id, reply.discussion_topic_id, reply.id)

    described_class.call('tahi:discussion_reply:created',
                         record: reply)
  end
end
