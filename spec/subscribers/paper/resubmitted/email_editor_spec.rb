require 'rails_helper'

describe Paper::Resubmitted::EmailEditor do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) { instance_double(Paper, id: 1, academic_editor: user) }
  let!(:user) { FactoryGirl.create(:user) }

  it "sends an email to the editor" do
    expect(mailer).to receive(:notify_editor_of_paper_resubmission).with(paper.id)
    described_class.call("tahi:paper:resubmitted", record: paper)
  end
end
