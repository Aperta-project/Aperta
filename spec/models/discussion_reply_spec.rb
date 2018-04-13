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

RSpec.describe DiscussionReply, type: :model, redis: true do
  let(:discussion_reply) { build :discussion_reply, body: old_body }
  let(:old_body) { "old" }
  let(:new_body) { "new" }

  describe "#create" do
    it "processes at-mentions on the body" do
      expect_any_instance_of(UserMentions)
        .to receive(:decorated_mentions).and_return(new_body)
      expect { discussion_reply.save! }.to change { discussion_reply.body }
        .from(old_body).to(new_body)
    end
  end

  describe "#sanitized_body" do
    let(:input_body) { "hi \n <div>foo</foo> @steve" }
    let(:formatted_body) { "<p>hi \n<br /> foo @steve</p>" }
    let(:discussion_reply) { build :discussion_reply, body: input_body }

    it 'strips sanitizes and formats the body and then adds at-mention links' do
      dbl = instance_double("UserMentions")
      expect(dbl).to receive(:decorated_mentions)
      expect(UserMentions).to receive(:new).with(formatted_body, anything, anything).and_return(dbl)
      discussion_reply.sanitized_body
    end
  end
end
