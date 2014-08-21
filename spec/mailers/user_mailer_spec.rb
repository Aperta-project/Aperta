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
end
