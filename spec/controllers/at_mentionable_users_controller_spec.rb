require 'rails_helper'

describe AtMentionableUsersController do
  let(:user) { create(:user) }
  let(:mentionable_user) { create(:user) }
  let!(:discussion_topic) { create(:discussion_topic) }
  let(:paper) { create(:paper) }

  before { sign_in user }

  describe '#index' do
    subject(:do_request) do
      get :index,
          format: :json,
          on_paper_id: paper.id
    end

    before do
      allow(User).to receive(:who_can).and_return [mentionable_user]
    end

    context 'the user is authorized' do
      it 'returns users who can be at-mentioned' do
        do_request
        expect(response.status).to eq 200
        data = JSON.parse(response.body)
        expect(data['users'].count).to eq 1
        user_data = data['users'].first
        expect(user_data['id']).to eq mentionable_user.id
      end
    end
  end
end
