require 'rails_helper'

require 'rails_helper'

describe VersionedTextsController do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  # this will have been automagically created by setting the paper
  # body
  let(:versioned_text) { VersionedText.where(paper: paper).first! }

  describe "GET 'show'" do
    subject(:do_request) { get :show, id: versioned_text.id, format: :json }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it 'returns a version' do
        expected_keys = %w(
          id
          text
          updated_at
          paper_id
          major_version
          minor_version
        )
        expect(res_body['versioned_text'].keys).to eq(expected_keys)
      end
    end

    context 'when the user does not have access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end

  end
end
