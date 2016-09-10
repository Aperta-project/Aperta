require 'rails_helper'

describe ManuscriptAttachmentsController do
  let(:attachment) do
    FactoryGirl.build_stubbed(:manuscript_attachment, paper: paper)
  end
  let(:paper){ FactoryGirl.build_stubbed(:paper) }
  let(:user) { FactoryGirl.build_stubbed :user }

  describe 'GET #show' do
    let(:attachment) { FactoryGirl.build_stubbed(:manuscript_attachment) }

    subject(:do_request) do
      get :show, format: 'json', id: attachment.to_param
    end

    before do
      allow(ManuscriptAttachment).to receive(:find)
        .with(attachment.to_param)
        .and_return(attachment)
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user is signed in' do
      before do
        stub_sign_in user
      end

      context 'when the user has access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, attachment.paper)
            .and_return true
        end

        it 'responds with the attachment' do
          do_request
          expect(res_body['attachment']['id']).to eq(attachment.id)
        end

        it 'returns 200 OK' do
          do_request
          expect(response.status).to eq(200)
        end
      end

      context 'when the user does not have access' do
        before do
          allow(user).to receive(:can?)
            .with(:view, attachment.paper)
            .and_return false
        end

        it 'returns a 403' do
          do_request
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
