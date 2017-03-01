require 'rails_helper'

describe CardsController do
  subject(:do_request) do
    get :show, format: 'json', id: card.id
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:my_journal) { FactoryGirl.create(:journal) }
  let(:my_other_journal) { FactoryGirl.create(:journal) }
  let(:not_my_journal) { FactoryGirl.create(:journal) }

  describe 'GET index' do
    subject(:do_request) { get :index, format: :json }
    it_behaves_like "an unauthenticated json request"

    before do
      FactoryGirl.create(:card, journal: my_journal, name: 'My Journal')
      FactoryGirl.create(:card, journal: my_other_journal, name: 'My Other Journal')
      FactoryGirl.create(:card, journal: not_my_journal, name: 'Not My Journal')
    end

    context 'and the user is signed in' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:filter_authorized).and_return(
          instance_double(
            'Authorizations::Query::Result',
            objects: [my_journal, my_other_journal]
          )
        )
      end

      context 'for all journals' do
        it { is_expected.to responds_with 200 }

        it 'returns cards for journals the user has access to' do
          do_request
          card_names = res_body['cards'].map { |h| h['name'] }
          expect(card_names).to contain_exactly('My Journal', 'My Other Journal')
        end
      end

      context 'for one journal' do
        it 'returns no cards for journals the user has no access to' do
          get :index, journal_id: not_my_journal.id, format: :json
          expect(res_body['cards'].count).to eq(0)
        end

        it 'returns all cards for the specified journal' do
          get :index, journal_id: my_journal.id, format: :json
          card_names = res_body['cards'].map { |h| h['name'] }
          expect(card_names).to contain_exactly('My Journal')
        end
      end
    end
  end

  describe "#show" do
    let(:user) { create :user, :site_admin }

    before do
      stub_sign_in user
    end

    context "the card exists" do
      let(:card) { FactoryGirl.create(:card) }

      it "returns a serialized card" do
        do_request
        expect(response.status).to eq(200)
        expect(res_body).to include("card")
      end
    end
  end

  context "authentication" do
    let(:card) { FactoryGirl.create(:card) }
    let(:object) { FactoryGirl.create(:cover_letter_task, card: card) }

    it_behaves_like 'an unauthenticated json request'
  end
end
