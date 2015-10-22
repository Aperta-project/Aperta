require 'rails_helper'

describe Paper::Submitted::EmailAdmins do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  before { assign_paper_role(paper, user, PaperRole::ADMIN) }

  it "sends an email to each admin" do
    expect(mailer).to receive(:notify_admin_of_paper_submission).with(paper.id, user.id)
    described_class.call("tahi:paper:submitted", { record: paper })
  end

end
