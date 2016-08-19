require 'rails_helper'

describe PlosBioTechCheck::ChangesForAuthorMailer do
  let(:author) { create :user }
  let(:paper) do
    create :paper, :with_integration_journal, :submitted, creator: author
  end
  let(:task) { create :changes_for_author_task, paper: paper }
  let(:email) { described_class.notify_changes_for_author author_id: author.id, task_id: task.id }

  it "sends an email to author" do
    expect(email.to.length).to eq 1
    expect(email.to.first).to eq author.email
    expect(email.body.raw_source).to match author.full_name
    expect(email.body.raw_source).to match paper.journal.name
    expect(email.body.raw_source).to include task.body['initialTechCheckBody']
    expect(email.body.raw_source).to match 'http://'
  end

  context "with line breaks in body .json content" do
    before do
      task.update_attribute(:body, {
        initialTechCheckBody: "with\nline\nbreaks"
      })
    end

    it "replace line breaks with html breaks" do
      expect(email.body).to_not include "with\nline\nbreaks"
      expect(email.body).to include "<p>with\n<br />line\n<br />breaks</p>"
    end
  end
end
