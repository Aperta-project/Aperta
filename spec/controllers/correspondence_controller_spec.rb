require 'rails_helper'

def correspondence_rbac(access)
  stub_sign_in user
  allow(user).to receive(:can?)
    .with(:manage_workflow, paper)
    .and_return access
end

def new_correspondence_params(paper)
  {
    sender: Faker::Internet.safe_email,
    recipients: Faker::Internet.safe_email,
    cc: Faker::Internet.safe_email,
    bcc: Faker::Internet.safe_email,
    sent_at: DateTime.now.in_time_zone.as_json,
    description: "A bleak description",
    subject: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraph,
    paper_id: paper.id
  }
end

describe CorrespondenceController do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  describe 'GET index' do
    subject(:do_request) do
      get :index, params: { format: 'json', paper_id: paper.id }
    end

    context 'when user has access' do
      let!(:correspondence_one) do
        FactoryGirl.create(:correspondence, :as_external, paper: paper)
      end
      let!(:correspondence_two) do
        FactoryGirl.create(:correspondence, :as_external, paper: paper)
      end

      before do
        correspondence_rbac(true)
      end

      it "returns the paper's correspondences" do
        do_request
        expect(res_body['correspondence'].count).to eq(2)
        expect(res_body['correspondence'][0]['id']).to eq(correspondence_two.id)
      end

      it 'returns status code 200' do
        is_expected.to have_http_status(200)
      end
    end

    context "when user does not have access" do
      before do
        correspondence_rbac(false)
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create,
                  format: 'json',
                  paper_id: paper.id,
                  correspondence: new_correspondence_params(paper)
    end

    context 'when user has access' do
      before do
        correspondence_rbac true
      end

      context 'when record is valid' do
        it 'creates a correspondence' do
          expect { do_request }.to change { Correspondence.count }.by 1
        end
      end
    end
  end
end
