require 'spec_helper'

describe Comment do

  let(:author) { FactoryGirl.create(:user) }
  let(:commenter) { FactoryGirl.create(:user) }

  context "validation" do
    it "will be valid with default factory data" do
      model = FactoryGirl.build(:comment)
      expect(model).to be_valid
    end
  end

  context "notifications" do
    it "send email on @mention" do
      expect {
        comment = FactoryGirl.create(:comment, body: "check this out @#{author.username}")
        # TODO: Refactor
        # must assign a user to the task. mustbeabetterway
        task = comment.task
        task.update_attribute(:assignee, author)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end

    it "send email on multiple, messy @mention" do
      expect {
        comment = FactoryGirl.create(:comment, body: "check this out @#{author.username} @#{author.username} @#{author.username} @#{author.username} @#{commenter.username}, @someOtherHandle like whoa!")
        task = comment.task
        task.update_attribute(:assignee, author)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(2)
    end

    it "does not send email without @mention" do
      expect {
        comment = FactoryGirl.create(:comment, body: "generic text with no mentions")
        task = comment.task
        task.update_attribute(:assignee, author)
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(0)
    end
  end
end
