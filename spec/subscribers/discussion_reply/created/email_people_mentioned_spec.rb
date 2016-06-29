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
