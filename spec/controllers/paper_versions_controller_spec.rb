require 'rails_helper'

describe PaperVersionsController do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  # this will have been automagically created by setting the paper
  # body
  let(:paper_version) { PaperVersion.where(paper: paper).first! }

  describe "GET 'show'" do
    subject(:do_request) { get :show, id: paper_version.id, format: :json }

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
          version_string
          file_type
          source_type
        )
        expect(res_body['paper_version'].keys).to eq(expected_keys)
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
