require 'spec_helper'

describe MessagesController do

  let(:user) { FactoryGirl.create :user, admin: super_admin }
  let(:super_admin) { false }
  before { sign_in user }

  describe "POST 'create'" do

    let(:paper) { FactoryGirl.create :paper, user: user }
    let(:msg_subject) { "A Subject" }
    subject(:do_request) do
      post :create, format: 'json',
        paper_id: paper.id,
        phase_id: paper.phases.first.id,
        task: {message_subject: msg_subject,
               message_body: "My body",
               participant_ids: [user.id]}
    end

    def verify_response(response)
        json = JSON.parse(response.body)
        expect(json["cardName"]).to eq("message")
        expect(json["messageSubject"]).to eq(msg_subject)
        expect(json["taskTitle"]).to eq(msg_subject)
        expect(json["comments"].count).to eq(1)
    end
    context "with a paper that the user administers through a journal" do
      let!(:journal_role) do
        paper.journal.journal_roles.create!(user: user, admin: true)
      end

      it "renders the new message as json." do
        do_request
        expect(response).to be_success
        verify_response(response)
      end

      context "with no subject" do
        let(:msg_subject) { nil }
        it "returns an error" do
          do_request
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)).to have_key("errors")
        end
      end
    end

    context "when the user doesn't administer the paper directly" do
      context "the user isn't a super admin" do
        it "renders 404" do
          do_request
          expect(response.status).to eq(404)
        end
      end

      context "the user is a super admin" do
        let(:super_admin) { true }
        it "renders the new message" do
          do_request
          expect(response).to be_success
          verify_response(response)
        end
      end
    end
  end
end
