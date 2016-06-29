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
end
