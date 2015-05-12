require 'rails_helper'
include ClientRouteHelper

describe UserMailer, redis: true do
  shared_examples_for "invitor is not available" do
    before { expect(invitee).to receive(:id).and_return(nil) }

    it "anonymizes the invitor" do
      expect(email.body).to match(/Someone/)
    end
  end

  shared_examples_for "recipient without email address" do
    before do
      invitee.tap do |user|
        user.email = ""
        user.save(validate: false)
      end
    end
    it "anonymizes the invitor" do
      expect(email.perform_deliveries).to eq(false)
    end
  end

  describe '#add_collaborator' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:email) { UserMailer.add_collaborator(invitor.id, invitee.id, paper.id) }

    it_behaves_like "invitor is not available"
    it_behaves_like "recipient without email address"

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you as a contributor/)
    end
  end

  describe '#add_participant' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:email) { UserMailer.add_participant(invitor.id, invitee.id, task.id) }

    it_behaves_like "invitor is not available"
    it_behaves_like "recipient without email address"

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you to a conversation/)
    end
  end

  describe '#assigned_editor' do
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:email) { UserMailer.assigned_editor(invitee.id, task.paper.id) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as an editor' do
      expect(email.body).to match(/been assigned as an editor/)
    end
  end

  describe '#mention_collaborator' do
    let(:admin) { FactoryGirl.create(:user, :site_admin) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :with_tasks, creator: admin, submitted: true }
    let(:comment) { FactoryGirl.create(:comment, task: paper.tasks.first) }
    let(:email) { UserMailer.mention_collaborator(comment, invitee) }

    it_behaves_like "recipient without email address"

    it 'sends the email to the mentioned user' do
      expect(email.to).to eq [invitee.email]
    end

    it 'tells the user they have been mentioned' do
      expect(email.body).to include "You've been mentioned by #{comment.commenter.full_name}"
      expect(email.body).to include paper.title
      expect(email.body).to include paper.tasks.first.title
      expect(email.body).to include comment.body
      expect(email.body).to include client_paper_task_url(paper, paper.tasks.first)
    end
  end

  describe '#paper_submission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :with_tasks, creator: author, submitted: true }
    let(:email) { UserMailer.paper_submission(paper.id) }

    it "sends the email to the paper's author" do
      expect(email.to).to eq [author.email]
    end

    it "emails the author user they have been mentioned" do
      expect(email.subject).to eq "Thank You for submitting a Manuscript on Tahi"
      expect(email.body).to include "Thank you for submitting your manuscript"
      expect(email.body).to include paper.title
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_editor_of_paper_resubmission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:editor) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :with_tasks, creator: author, submitted: true }
    let(:email) { UserMailer.notify_editor_of_paper_resubmission(paper.id) }

    before do
      make_user_paper_editor(editor, paper)
    end

    it "send email to the paper's editor" do
      expect(email.to).to eq [editor.email]
    end

    it "specify subject line" do
      expect(email.subject).to eq "Manuscript has been resubmitted in Tahi"
    end

    it "tells the editor paper has been (re)submitted" do
      expect(email.body).to include "Hello #{editor.full_name}"
      expect(email.body).to include "#{author.full_name} has resubmitted the manuscript"
      expect(email.body).to include paper.title
      expect(email.body).to include client_paper_url(paper)
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_admin_of_paper_submission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :with_tasks, creator: author, submitted: true }
    let(:email) { UserMailer.notify_admin_of_paper_submission(paper.id, admin.id) }

    before do
      make_user_paper_admin(admin, paper)
    end

    it "send email to the paper's admin" do
      expect(email.to).to eq [admin.email]
    end

    it "specify subject line" do
      expect(email.subject).to eq "Manuscript #{paper.title} has been submitted on Tahi"
    end

    it "tells admin that paper has been submitted" do
      expect(email.body).to include "Hello #{admin.full_name}"
      expect(email.body).to include "The following Paper has been submitted:"
      expect(email.body).to include paper.abstract
      expect(email.body).to include client_paper_url(paper)
      expect(email.body).to include paper.journal.name
    end
  end
end
