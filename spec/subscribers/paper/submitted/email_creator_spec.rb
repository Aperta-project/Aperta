require 'rails_helper'

describe Paper::Submitted::EmailCreator do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator)
  end

  describe "when a paper is submitted" do
    it "notifies the creator of a submission" do
      expect(mailer).to receive(:notify_creator_of_paper_submission).with(paper.id)
      described_class.call("tahi:paper:submitted", event_name: 'submit',
                                                   record: paper)
    end

    it "notifies the creator of a minor revision submission" do
      expect(mailer).to receive(:notify_creator_of_revision_submission).with(paper.id)
      described_class.call("tahi:paper:submitted", event_name: 'submit_minor_revision',
                                                   record: paper)
    end
  end
end
