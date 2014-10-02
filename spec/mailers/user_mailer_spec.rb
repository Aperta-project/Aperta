require 'spec_helper'

describe UserMailer do
  describe '#add_collaborator' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:email) { UserMailer.add_collaborator(invitor.id, invitee.id, paper.id) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you as a contributor/)
    end
  end

  describe '#assign_task' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:email) { UserMailer.assign_task(invitor.id, invitee.id, task.id) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/just assigned the/)
    end
  end

  describe '#add_participant' do
    let(:invitor) { FactoryGirl.create(:user) }
    let(:invitee) { FactoryGirl.create(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:email) { UserMailer.add_participant(invitor.id, invitee.id, task.id) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you to a conversation/)
    end
  end

  describe '#mention_collaborator' do
    let(:admin) { FactoryGirl.create(:user, admin: true) }
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true }
    let(:comment) { FactoryGirl.create(:comment, task: paper.tasks.first) }

    let(:email) { UserMailer.mention_collaborator(admin.id, user.id, comment.id) }

    it 'sends the email to the mentioned user' do
      expect(email.to).to eq [user.email]
    end

    it 'tells the user they have been mentioned' do
      expect(email.body).to include "You've been mentioned"
      expect(email.body).to include admin.full_name
      expect(email.body).to include paper.title
      expect(email.body).to include paper.tasks.first.title
      expect(email.body).to include comment.body
      expect(email.body).to include paper_task_url(paper.id, paper.tasks.first.id)
    end
  end
end
