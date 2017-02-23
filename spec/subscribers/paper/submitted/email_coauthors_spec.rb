require 'rails_helper'

describe Paper::Submitted::EmailCoauthors do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let!(:paper) do
    FactoryGirl.build_stubbed(:paper)
  end
  let!(:creator) do
    FactoryGirl.build_stubbed(:user)
  end
  let!(:author_1) do
    FactoryGirl.build_stubbed(:author, email: creator.email)
  end
  let!(:author_2) do
    FactoryGirl.build_stubbed(:group_author)
  end
  let!(:author_3) do
    FactoryGirl.build_stubbed(:author)
  end

  describe "when the paper is submitted" do
    it "notifies the coauthors if it is being submitted for the first time" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["unsubmitted", "submitted"]
      )
      allow(paper).to receive(:all_authors).and_return([author_1, author_2, author_3])
      allow(paper).to receive(:creator).and_return(creator)
      expect(mailer).to receive(:notify_coauthor_of_paper_submission)
        .with(paper.id, author_2.id, "GroupAuthor")
      expect(mailer).to receive(:notify_coauthor_of_paper_submission)
        .with(paper.id, author_3.id, "Author")
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "notifies the coauthors if the paper has been accepted for full submission" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["invited_for_full_submission", "submitted"]
      )
      allow(paper).to receive(:all_authors).and_return([author_1, author_2, author_3])
      allow(paper).to receive(:creator).and_return(creator)
      expect(mailer).to receive(:notify_coauthor_of_paper_submission)
        .with(paper.id, author_2.id, "GroupAuthor")
      expect(mailer).to receive(:notify_coauthor_of_paper_submission)
        .with(paper.id, author_3.id, "Author")
      described_class.call("tahi:paper:submitted", record: paper)
    end

    it "does not send an email when the paper has already been submitted" do
      allow(paper).to receive(:previous_changes).and_return(
        publishing_state: ["in_revision", "submitted"]
      )
      expect(mailer).to_not receive(:notify_coauthor_of_paper_submission)
      described_class.call("tahi:paper:submitted", record: paper)
    end
  end
end
