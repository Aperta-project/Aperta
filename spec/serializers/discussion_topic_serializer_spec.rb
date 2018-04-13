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
