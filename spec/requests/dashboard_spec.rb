require "rails_helper"

describe "Dashboard" do

  let(:user) { FactoryGirl.create(:user) }

  before { login(user) }

  context "GET /dashboards" do

    let!(:invitation) { FactoryGirl.create(:invitation, invitee: user) }

    it "sends invitations as part of the dashboard" do
      get(dashboards_path, format: :json)
      expect(response.status).to eq(200)

      data = JSON.parse(response.body).with_indifferent_access

      invitation_ids = data[:dashboards][0][:invitation_ids]
      expect(invitation_ids.length).to eq(1)

      invitation_json = data[:invitations].find { |i| i[:id] == invitation.id }

      expect(invitation_json[:id]).to eq(invitation.id)
      expect(invitation_json[:state]).to eq("pending")
      expect(invitation_json[:title]).to eq(invitation.paper.title)
      expect(invitation_json[:abstract]).to eq(invitation.paper.abstract)
    end

  end

end
