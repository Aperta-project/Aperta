require 'rails_helper'
require 'sidekiq/testing'

describe CollaborationsController do
  describe "#create" do
    let(:user) { FactoryGirl.create(:user) }

    let(:invitee) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, creator: user) }

    let(:collab_params) { { user_id: invitee.id, paper_id: paper.id }}

    before { sign_in user }

    it 'adds activities to the feeds' do
      expect {
        post :create, format: :json, collaboration: collab_params
      }.to change(Activity, :count).by(1)
    end

    it 'adds an email to the sidekiq queue' do
      expect {
        post :create, format: :json, collaboration: collab_params
      }.to change(Sidekiq::Extensions::DelayedMailer.jobs, :size).by(1)
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user) }

    let(:paper) { FactoryGirl.create(:paper, creator: user) }
    let!(:collaborator) { FactoryGirl.create(:paper_role, :collaborator, paper: paper) }

    before { sign_in user }

    it 'adds activities to the feeds' do
      expect {
        delete :destroy, format: :json, id: collaborator.id, paper_id: paper.id
      }.to change(Activity, :count).by(1)
    end
  end
end
