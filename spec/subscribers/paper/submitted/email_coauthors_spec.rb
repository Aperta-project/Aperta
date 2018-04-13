# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

  let! (:setting_template) do
    FactoryGirl.create(:setting_template,
     key: "Journal",
     setting_name: "coauthor_confirmation_enabled",
     value_type: 'boolean',
     boolean_value: true)
  end

  describe "when the paper is submitted" do
    before do
      allow(paper).to receive(:all_authors).and_return([author_1, author_2, author_3])
      allow(paper).to receive(:creator).and_return(creator)
    end

    context "and coauthor_confirmation is enabled" do
      it "notifies the coauthors if it is being submitted for the first time" do
        allow(paper).to receive(:previous_changes).and_return(
          publishing_state: ["unsubmitted", "submitted"]
        )
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

    context "and coauthor_confirmation is disabled" do
      it "does not notify the coauthor" do
        paper.journal.setting("coauthor_confirmation_enabled").update(value: false)

        allow(paper).to receive(:previous_changes).and_return(
          publishing_state: ["in_revision", "submitted"]
        )

        expect(mailer).to_not receive(:notify_coauthor_of_paper_submission)
      end
    end
  end
end
