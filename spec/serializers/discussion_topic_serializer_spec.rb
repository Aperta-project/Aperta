require 'rails_helper'

describe DiscussionTopicSerializer, serializer_test: true do
  let(:discussion) do
    FactoryGirl.create(
      :discussion_topic,
      participants: [discussant],
      discussion_replies: [reply],
      discussion_participants: [discussion_participant]
    )
  end
  let(:reply) { FactoryGirl.create(:discussion_reply, replier: discussant) }
  let(:discussant) { FactoryGirl.create(:user) }
  let(:object_for_serializer) { discussion }
  let(:discussion_participant) { FactoryGirl.create(:discussion_participant, user: discussant) }

  it 'serializes the topic' do
    expect(deserialized_content)
      .to match(hash_including(discussion_topic: hash_including(title: discussion.title)))
  end

  it 'serializes the reply' do
    expect(deserialized_content)
      .to match(hash_including(discussion_replies:
                                 include(hash_including(body: reply.body,
                                                        replier_id: discussant.id))))
  end

  context 'with a replying discussant who is not a participant' do
    subject(:discussion) do
      FactoryGirl.create(
        :discussion_topic,
        discussion_replies: [reply]
      )
    end

    it 'serializes all repliers although they may not be participants' do
      expect(deserialized_content).to match(hash_including(users: include(hash_including(id: discussant.id))))
    end
  end

  context 'with a replying discussant who also a participant' do
    it 'serializes the discussant only once' do
      expect(deserialized_content).to match(hash_including(users: contain_exactly(hash_including(id: discussant.id))))
    end
  end
end
