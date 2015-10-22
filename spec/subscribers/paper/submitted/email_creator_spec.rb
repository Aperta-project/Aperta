require 'rails_helper'

describe Paper::Submitted::EmailCreator do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, creator: user) }

  it "sends an email to the creator of the paper" do
    expect(mailer).to receive(:notify_creator_of_paper_submission).with(paper.id)
    described_class.call("tahi:paper:submitted", { record: paper })
  end

end
