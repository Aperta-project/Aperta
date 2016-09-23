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
