require 'spec_helper'

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
    before { ActionMailer::Base.deliveries.clear }

    it "send email on @mention" do
      expect {
        FactoryGirl.create(:comment, body: "check this out @#{author.username}")
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end

    it "send email on multiple, messy @mention" do
      expect {
        FactoryGirl.create(:comment, body: "check this out @#{author.username} @#{commenter.username} @#{author2.username}, @someOtherHandle like whoa!", commenter: commenter )
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).from(0).to(2)

      Sidekiq::Extensions::DelayedMailer.drain
      expect(ActionMailer::Base.deliveries.collect(&:to).flatten).to match_array [author.email, author2.email]
    end

    it "does not send email without @mention" do
      expect {
        FactoryGirl.create(:comment, body: "generic text with no mentions")
      }.to_not change(Sidekiq::Extensions::DelayedMailer.jobs, :size)
    end
  end
end
