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
    it "#sanitize_body" do
      body = "hi @#{author.username}. Trying to break comment with <script>alert('bad script')</script>"
      comment = FactoryGirl.create(:comment, body: body)
      expected = "hi @#{author.username}. Trying to break comment with &lt;script&gt;alert(&#39;bad script&#39;)&lt;/script&gt;"
      expect(comment.body).to eq expected
    end

    it "#set_mentions" do
      body = "hi @#{author.username}, @#{author2.username}, and @nonexistent_user"
      comment = FactoryGirl.create(:comment, body: body)
      expected = {:indices=>[3, 3+('@'+author.username).length]}
      expect(comment.entities['user_mentions'][0]).to eq expected
      expect(comment.entities['user_mentions'].length).to eq 2
    end
  end

  context "notifications" do
    include ActiveJob::TestHelper

    before { ActionMailer::Base.deliveries.clear }
    after  {clear_enqueued_jobs}

    it "send email on @mention" do
      FactoryGirl.create(:comment, body: "check this out @#{author.username}")
      expect(enqueued_jobs.size).to eq 1
    end

    it "send email on multiple, messy @mention" do
      FactoryGirl.create(:comment, body: "check this out @#{author.username} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter )
      expect(enqueued_jobs.size).to eq 2
    end

    it "send email on multiple, messy @mention, verify the emails sent" do
      perform_enqueued_jobs do
        FactoryGirl.create(:comment, body: "check this out @#{author.username} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter )
      end
      expect(ActionMailer::Base.deliveries.flat_map(&:to)).to match_array [author.email, author2.email]
    end

    it "does not send email without @mention" do
      expect {
        FactoryGirl.create(:comment, body: "generic text with no mentions")
      }.to_not change(enqueued_jobs, :size)
    end
  end
end
