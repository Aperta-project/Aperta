require 'rails_helper'

describe CorrespondenceController do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  describe 'GET index' do
    subject(:do_request) do
      get :index, format: 'json',
                  paper_id: paper.id
    end

    context 'when user has access' do
      let!(:first_correspondence) do
        FactoryGirl.create(:external_correspondence, paper: paper)
      end
      let!(:second_correspondence) do
        FactoryGirl.create(:external_correspondence, paper: paper)
      end

      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      it "returns the paper's correspondences" do
        do_request
        expect(res_body['correspondence'].count).to eq(2)
        expect(res_body['correspondence'][0]['id']).to eq(second_correspondence.id)
      end
    end

    context "when user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'POST create' do
    subject(:do_request) do
      xhr :post, :create,
                  format: 'json',
                  external_correspondence: {
                    sender: "#{Faker::Name.name} <#{Faker::Internet.safe_email}>",
                    recipients: "#{Faker::Name.name} <#{Faker::Internet.safe_email}>",
                    sent_at: DateTime.now.in_time_zone.as_json,
                    description: "A bleak description",
                    body: Faker::Lorem.paragraph,
                    paper_id: paper.id
                  }
    end

    context 'when user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      context 'when record is valid' do
        it 'creates a correspondence' do
          expect { do_request }.to change { Correspondence.count }.by 1
        end
      end
    end
  end
end
