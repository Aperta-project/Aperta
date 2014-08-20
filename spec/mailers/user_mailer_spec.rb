require 'spec_helper'

describe UserMailer do
  describe '#add_collaborator' do
    let(:invitor) { FactoryGirl.build(:user) }
    let(:invitee) { FactoryGirl.build(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:email) { UserMailer.add_collaborator(invitor, invitee, paper) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/added you as a contributor/)
    end
  end

  describe '#add_collaborator' do
    let(:invitor) { FactoryGirl.build(:user) }
    let(:invitee) { FactoryGirl.build(:user) }
    let(:task) { FactoryGirl.create(:task) }
    let(:email) { UserMailer.assign_task(invitor, invitee, task) }

    it 'sends the email to the inivitees email address' do
      expect(email.to).to include(invitee.email)
    end

    it 'tells the user they have been added as a collaborator' do
      expect(email.body).to match(/just assigned the/)
    end
  end
end
