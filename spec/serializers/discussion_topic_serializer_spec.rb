require 'rails_helper'

describe DiscussionTopicSerializer, serializer_test: true do
  subject(:discussion) do
    FactoryGirl.create(
      :discussion_topic,
      participants: [user],
      discussion_replies: [reply])
  end
  let(:reply) { FactoryGirl.create(:discussion_reply, replier: user) }
  let(:user) { FactoryGirl.create(:user) }

  it 'serializes the topic' do
    expect(deserialized_content)
      .to match(hash_including(discussion_topic: hash_including(title: discussion.title)))
  end

  it 'serializes the reply' do
    expect(deserialized_content)
      .to match(hash_including(discussion_replies:
                                 include(hash_including(body: reply.body,
                                                        replier_id: user.id))))
  end

  context 'with a replying user who is not a participant' do
    subject(:discussion) do
      FactoryGirl.create(
        :discussion_topic,
        discussion_replies: [reply])
    end

    it 'serializes all repliers although they may not be participants' do
      expect(deserialized_content).to match(hash_including(users: include(hash_including(id: user.id))))
    end
  end

  context 'with a replying user who also a participant' do
    it 'serializes the user only once' do
      expect(deserialized_content).to match(hash_including(users: contain_exactly(hash_including(id: user.id))))
    end
  end
end
