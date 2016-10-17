require 'rails_helper'

describe OrcidOauthController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }
  let(:code) { '123456' }
  let(:error) { 'some_error' }

  describe '#callback:' do

    # it_behaves_like "when the user is not signed in"

    context 'when the user is signed in,' do
      before do
        stub_sign_in(user)
      end
      
      context 'and there is an error passed in,' do
        subject(:do_request) do
          get :callback, error: error, format: :html
        end

        it "does not call the OrcidWorker" do
          expect(OrcidWorker).not_to receive(:perform_async)
          do_request
        end
      end
      
      context 'and there is no error passed in,' do
        subject(:do_request) do
          get :callback, code: code, format: :html
        end

        it "calls the OrcidWorker" do
          allow(controller).to receive(:current_user).and_return(user)
          allow(OrcidWorker).to receive(:perform_async)
          expect(OrcidWorker).to receive(:perform_async).with(user.id, code)
          do_request
        end
      end
    end
  end
end
