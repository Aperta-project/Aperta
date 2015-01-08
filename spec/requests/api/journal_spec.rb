require 'rails_helper'

describe Api::JournalsController do
  describe "GET 'index'" do
    let!(:journal1) { create :journal }
    let!(:journal2) { create :journal }
    let(:api_token) { ApiKey.generate! }

    it 'returns a list of journals in the system' do
      get api_journals_path, nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials(api_token)
      data = JSON.parse response.body
      expect(data).to eq (
        {
          journals: [
            { id: journal1.id, name: journal1.name },
            { id: journal2.id, name: journal2.name }
          ]
        }.with_indifferent_access
      )
    end

    context "when there is no API token provided" do
      it "doesn't return a list of journals in the system" do
        get api_journals_path
        expect(response.status).to eq(401)
      end
    end
  end
end
