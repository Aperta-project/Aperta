require 'rails_helper'

describe DiscussionParticipantsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper) }
  let!(:paper_role) { FactoryGirl.create(:paper_role, :editor, paper: paper, user: user) }
  let!(:topic_a) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let!(:participation) { topic_a.discussion_participants.create!(user: user) }

  let(:json) { res_body }

  before { sign_in user }

  describe 'POST create' do
    render_views

    let(:creation_params) do
      {
        discussion_participant: {
          discussion_topic_id: topic_a.id,
          user_id: another_user.id,
        }
      }
    end

    it "adds a user to a discussion" do
      expect {
        xhr :post, :create, format: :json, **creation_params
      }.to change { DiscussionParticipant.count }.by(1)

      participant = json["discussion_participant"]
      expect(participant['discussion_topic_id']).to eq(topic_a.id)
      expect(participant['user_id']).to eq(another_user.id)
    end

  end

  describe 'DELETE destroy' do

    it "removes a user from a discussion" do
      expect {
        xhr :delete, :destroy, format: :json, id: participation.id
      }.to change { DiscussionParticipant.count }.by(-1)
    end

  end


end
