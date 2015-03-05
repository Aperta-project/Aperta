require 'rails_helper'

describe DashboardsController do

  describe "GET 'show'" do
    let(:user) { create :user }
    before { sign_in user }

    let(:do_request) { get :show }

    it_behaves_like "when the user is not signed in"

    it "returns http success" do
      do_request
      expect(response).to be_success
    end

    it "renders the dashboard info as json" do
      do_request
      json = JSON.parse(response.body)
      expect(json.keys).to match_array %w(dashboards lite_papers users affiliations invitations)
    end

    context "invitations" do

      let!(:invitation) { FactoryGirl.create(:invitation, :invited, invitee: user) }

      it "returns required fields" do
        do_request
        data = JSON.parse(response.body).with_indifferent_access

        invitation_ids = data[:dashboards][0][:invitation_ids]
        expect(invitation_ids.length).to eq(1)

        invitation_json = data[:invitations].find { |i| i[:id] == invitation.id }

        expect(invitation_json[:id]).to eq(invitation.id)
        expect(invitation_json[:state]).to eq("invited")
        expect(invitation_json[:title]).to eq(invitation.paper.title)
        expect(invitation_json[:abstract]).to eq(invitation.paper.abstract)
      end
    end
  end
end
