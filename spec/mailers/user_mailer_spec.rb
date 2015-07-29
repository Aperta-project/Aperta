require 'rails_helper'
include ClientRouteHelper

describe UserMailer, redis: true do
  let(:app_name) { 'TEST-APP-NAME' }

  before do
    allow_any_instance_of(MailerHelper).to receive(:app_name).and_return app_name
    allow_any_instance_of(TemplateHelper).to receive(:app_name).and_return app_name
  end

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
      expect(email.body).to match(/added you as a collaborator/)
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

  describe '#add_editor_to_editors_discussion' do
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:editors_discussion_task) }
    let(:email) { UserMailer.add_editor_to_editors_discussion(invitee.id, task.id) }
    let(:abstract) { 'Tongue twister tong t.' }

    before { task.paper.update! body: "Dragon red blue green yellow." }

    context 'when the paper has an abstract' do
      it 'sends a specific email to the editor invitee' do
        task.paper.update! abstract: abstract
        expect(email.subject).to eq "You've been invited to the Editor Discussion for manuscript \"#{task.paper.display_title}\""
        expect(email.body).to include 'View Discussion'
        expect(email.body).to include abstract
      end
    end

    context 'when the paper has no abstract' do
      it 'sends a specific email to the editor invitee' do
        expect(email.subject).to eq "You've been invited to the Editor Discussion for manuscript \"#{task.paper.display_title}\""
        expect(email.body).to include 'View Discussion'
        expect(email.body).to_not include abstract
        expect(email.body).to match task.paper.body
      end
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
      expect(email.body).to match(/been assigned as an Editor/)
    end
  end

  describe '#mention_collaborator' do
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:paper) { task.paper }
    let(:comment) { FactoryGirl.create(:comment, task: task) }

    let(:email) { UserMailer.mention_collaborator(comment.id, invitee.id) }

    it_behaves_like "recipient without email address"

    it 'sends the email to the mentioned user' do
      expect(email.to).to eq [invitee.email]
    end

    it 'tells the user they have been mentioned' do
      expect(email.body).to include "You've been mentioned by #{comment.commenter.full_name}"
      expect(email.body).to include paper.display_title
      expect(email.body).to include paper.tasks.first.title
      expect(email.body).to include comment.body
      expect(email.body).to include client_paper_task_url(paper, paper.tasks.first)
    end
  end

  describe '#paper_submission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, creator: author }
    let(:email) { UserMailer.paper_submission(paper.id) }

    it "sends the email to the paper's author" do
      expect(email.to).to eq [author.email]
    end

    it "emails the author user they have been mentioned" do
      expect(email.subject).to eq "Thank you for submitting a manuscript on #{app_name}"
      expect(email.body).to include "Thank you for submitting your manuscript"
      expect(email.body).to include paper.title
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_editor_of_paper_resubmission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:editor) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, creator: author}
    let(:email) { UserMailer.notify_editor_of_paper_resubmission(paper.id) }

    before do
      make_user_paper_editor(editor, paper)
    end

    it "send email to the paper's editor" do
      expect(email.to).to eq [editor.email]
    end

    it "specify subject line" do
      expect(email.subject).to eq "Manuscript has been resubmitted in #{app_name}"
    end

    it "tells the editor paper has been (re)submitted" do
      expect(email.body).to include "Hello #{editor.first_name}"
      expect(email.body).to include "A new version has been submitted"
      expect(email.body).to include paper.title
      expect(email.body).to include client_paper_url(paper)
      expect(email.body).to include paper.journal.name
    end
  end

  describe '#notify_admin_of_paper_submission' do
    let(:author) { FactoryGirl.create(:user) }
    let(:admin) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, creator: author }
    let(:email) { UserMailer.notify_admin_of_paper_submission(paper.id, admin.id) }

    before do
      make_user_paper_admin(admin, paper)
    end

    it "send email to the paper's admin" do
      expect(email.to).to eq [admin.email]
    end

    it "specify subject line" do
      expect(email.subject).to eq "Manuscript #{paper.title} has been submitted on #{app_name}"
    end

    it "tells admin that paper has been submitted" do
      expect(email.body).to include "Hello #{admin.first_name}"
      expect(email.body).to include "A new version has been submitted"
      expect(email.body).to include paper.abstract
      expect(email.body).to include client_paper_url(paper)
      expect(email.body).to include paper.journal.name
    end
  end
end
