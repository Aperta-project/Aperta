require 'rails_helper'

describe UsersController do
  let(:user) { FactoryGirl.create :user }
  let(:url) { "www.example.com/foo.jpg" }

  describe '#update_avatar' do
    subject(:do_request) do
      put :update_avatar,
          format: 'json',
          url: url
    end

    it_behaves_like 'an unauthenticated json request'
    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it 'downloads the given avatar for current user' do
        expect(DownloadAvatar).to receive(:call).with(user, url)
        do_request
      end

      it "renders the current user's url on success" do
        allow(DownloadAvatar).to receive(:call).and_return(true)

        do_request
        expect(res_body['avatar_url']).to eq(user.avatar.url)
      end

      it 'responds with a 500 on failure' do
        allow(DownloadAvatar).to receive(:call).and_return(false)

        do_request
        expect(response.status).to eq(500)
      end
    end
  end

  describe '#show' do
    subject(:do_request) do
      get :show, id: user.id, format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end

      it "calls the users's serializer when rendering JSON" do
        expect_any_instance_of(UsersController).to receive(:requires_user_can).with(:manage_user, Journal) { true }
        do_request
        serializer = user.active_model_serializer.new(user, scope: user)
        expect(res_body.keys).to match_array(serializer.as_json.stringify_keys.keys)
      end
    end
  end
end
