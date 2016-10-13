require 'rails_helper'

describe OrcidOauthController do
  let(:user) { FactoryGirl.create :user }
  let(:orcid_account) { user.orcid_account }
  let(:orcid_worker) {  }

  describe '#callback' do
    subject(:do_request_with_error) do
      get :callback, id: user.id, format: :html
    end
    subject(:do_request_without_error) do
      get :callback, id: user.id, format: :html
    end

    it_behaves_like "when the user is not signed in"    

    context 'when the user is signed in' do
      before do
        stub_sign_in(user)
      end
      
      it "calls the OrcidWorker if no error is passed in" do        
        do_request_without_error
        expect(OrcidWorker).to receive(:perform_async).with(user.id, anything)
      end
      
      it "does not call the OrcidWorker if an error is passed in" do
        do_request_with_error
        expect(OrcidWorker).not_to receive(:perform_async)          
      end
    end
  end
end
