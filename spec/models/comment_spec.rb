require 'rails_helper'

describe Comment, redis: true do

  let(:author) { FactoryGirl.create(:user) }
  let(:author2) { FactoryGirl.create(:user) }
  let(:commenter) { FactoryGirl.create(:user) }

  context "validation" do
    it "will be valid with default factory data" do
      model = FactoryGirl.build(:comment)
      expect(model).to be_valid
    end
  end

  context "creating a new Comment" do
    it "sanitize the body" do
      body = "hi @#{author.username}. Trying to break comment with <script>alert('bad script')</script>"
      comment = FactoryGirl.create(:comment, body: body)
      expected = "hi @#{author.username}. Trying to break comment with &lt;script&gt;alert(&#39;bad script&#39;)&lt;/script&gt;"
      expect(comment.body).to eq expected
    end

    it "set the mentions with indices to entities attribute" do
      body = "hi @#{author.username}, @#{author2.username}, and @nonexistent_user"
      comment = FactoryGirl.create(:comment, body: body)
      first_username_length = "@#{author.username}".length

      expected = { "screen_name" => author.username, "indices" => [3, 3 + first_username_length] }
      expect(comment.entities["user_mentions"][0]).to eq expected
      expect(comment.entities["user_mentions"].length).to eq 3
    end
  end

  context "notifications" do
    include ActiveJob::TestHelper

    before { ActionMailer::Base.deliveries.clear }
    after  { clear_enqueued_jobs }

    def create_comment_and_notify_mentions(options = {})
      comment = FactoryGirl.create(:comment, options)
      comment.notify_mentioned_people
    end

    it "send email on @mention" do
      create_comment_and_notify_mentions(body: "check this out @#{author.username}")
      expect(enqueued_jobs.size).to eq 1
    end

    it "send email on multiple, messy @mention" do
      create_comment_and_notify_mentions(body: "check this out @#{author.username} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter)
      expect(enqueued_jobs.size).to eq 2
    end

    it "send email on multiple @mention to existing users" do
      perform_enqueued_jobs do
        create_comment_and_notify_mentions(body: "check this out @#{author.username} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter)
      end
      expect(ActionMailer::Base.deliveries.flat_map(&:to)).to match_array [author.email, author2.email]
    end

    it "does not send email without @mention" do
      expect {
        create_comment_and_notify_mentions(body: "generic text with no mentions")
      }.to_not change(enqueued_jobs, :size)
    end
  end
end
