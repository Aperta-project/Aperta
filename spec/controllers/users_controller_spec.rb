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
end
