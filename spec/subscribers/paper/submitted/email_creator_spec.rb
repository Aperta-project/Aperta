require 'rails_helper'

describe Paper::Submitted::EmailCreator do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) do
    FactoryGirl.build_stubbed(:paper)
  end

  describe "when a paper is submitted" do
    it "notifies the creator of a submission" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["unsubmitted", "submitted"])
      expect(mailer).to receive(:notify_creator_of_paper_submission)
        .with(paper.id)
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "notifies the creator of an initial submission" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["unsubmitted", "initially_submitted"])
      allow(paper).to receive(:publishing_state)
        .and_return("initially_submitted")
      expect(mailer).to receive(:notify_creator_of_initial_submission)
        .with(paper.id)
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "notifies the creator of a revision (major or minor) submission" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["in_revision", "submitted"])
      expect(mailer).to receive(:notify_creator_of_revision_submission).with(paper.id)
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "notifies the creator of a tech check submission" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["checking", "submitted"])
      expect(mailer).to receive(:notify_creator_of_check_submission).with(paper.id)
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "defaults to the submission email" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["does_not_exist", "submitted"])
      expect(mailer).to receive(:notify_creator_of_paper_submission).with(paper.id)
      described_class.call("tahi:paper:submitted", record: paper)
    end
  end
end
