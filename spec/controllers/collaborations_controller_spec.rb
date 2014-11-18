require 'spec_helper'
require 'sidekiq/testing'

describe CollaborationsController do
  describe 'POST "create"' do
    let(:user) { create :user }

    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, creator: user) }

    let(:collab_params) { { user_id: invitee.id, paper_id: paper.id }}

    before { sign_in user }

    it 'adds an email to the sidekiq queue' do
      expect {
        post :create, format: :json, collaboration: collab_params
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end
  end
end
