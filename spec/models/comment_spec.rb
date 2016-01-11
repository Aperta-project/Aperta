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

  context "notifications" do
    include ActiveJob::TestHelper

    before { ActionMailer::Base.deliveries.clear }
    after  { clear_enqueued_jobs }

    def create_comment_and_notify_mentions(options = {})
      comment = FactoryGirl.create(:comment, options)
    end

    it "send email on @mention" do
      create_comment_and_notify_mentions(body: "check this out @#{author.username}")
      expect(enqueued_jobs.size).to eq 1
    end

    it "send email on mixed-case @mention" do
      create_comment_and_notify_mentions(body: "check this out @#{author.username.upcase} and @#{author2.username.capitalize}", commenter: commenter)
      expect(enqueued_jobs.size).to eq 2
    end

    it "send email on multiple, messy @mention" do
      create_comment_and_notify_mentions(body: "check this out @#{author.username.upcase} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter)
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
