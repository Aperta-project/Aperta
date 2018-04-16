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

    it "does not send an email when the last decision was rescinded" do
      allow(paper).to receive(:latest_decision_rescinded?).and_return(true)

      expect(mailer).to_not receive(:notify_creator_of_paper_submission)
      expect(mailer).to_not receive(:notify_creator_of_initial_submission)
      expect(mailer).to_not receive(:notify_creator_of_revision_submission)
      expect(mailer).to_not receive(:notify_creator_of_check_submission)
      described_class.call("tahi:paper:submitted", record: paper)
    end
  end
end
