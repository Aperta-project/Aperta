require 'rails_helper'

describe CardsController do
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
    subject(:do_request) do
      get :show, format: 'json', id: card.id
    end
    let(:card) { FactoryGirl.create(:card) }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "when the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:view, card)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?).with(:view, card).and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'returns the serialized card' do
          do_request
          expect(res_body['card']['id']).to be card.id
        end
      end
    end
  end

  describe "#create" do
    subject(:do_request) do
      post(:create, format: 'json', card: {
             name: name,
             journal_id: my_journal.id
           })
    end
    let(:name) { "Steve" }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "when the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:create_card, my_journal)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:create_card, my_journal)
            .and_return(true)
        end

        it { is_expected.to responds_with 201 }

        it 'returns the serialized card' do
          do_request
          expect(res_body['card']['name']).to eq name
        end
      end
    end
  end

  describe '#update' do
    let(:card) { FactoryGirl.create(:card, journal: my_journal, name: 'An Old Name') }
    let(:name) { 'A New Name' }

    subject(:do_request) do
      put :update, format: 'json', id: card.id, card: {
        name: name
      }
    end

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context "when the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit_card, my_journal)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?)
            .with(:edit_card, my_journal)
            .and_return(true)
        end

        it { is_expected.to responds_with 204 }

        it 'updates the card' do
          do_request
          expect(card.reload.name).to eq(name)
        end
      end
    end
  end
end
