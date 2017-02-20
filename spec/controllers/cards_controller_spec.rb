describe CardsController do
  subject(:do_request) do
    get :show, format: 'json', owner_type: object.class.name.underscore, owner_id: object.id
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:my_journal) { FactoryGirl.create(:journal) }
  let(:my_other_journal) { FactoryGirl.create(:journal) }
  let(:not_my_journal) { FactoryGirl.create(:journal) }

  describe 'GET index' do
    subject(:do_request) { get :index, format: :json }
    it_behaves_like "an unauthenticated json request"

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

        it 'returns task types for journals the user has access to' do
          do_request
          cards = res_body['cards']
          all_tasks = (my_journal.journal_task_types.count +
                       my_other_journal.journal_task_types.count)
          expect(cards.count).to eq(all_tasks)
        end
      end

      context 'for one journal' do
        it 'returns no task types for journals the user has no access to' do
          get :index, journal_id: not_my_journal.id, format: :json
          expect(res_body['cards'].count).to eq(0)
        end

        it 'returns all task types for a journal the user has access to' do
          get :index, journal_id: my_journal.id, format: :json
          cards = res_body['cards']
          expect(cards.count).to eq(my_journal.journal_task_types.count)
        end
      end
    end
  end

  describe "#show" do
    let(:user) { create :user, :site_admin }

    before do
      stub_sign_in user
    end

    context "resource is answerable" do
      let(:card) { FactoryGirl.create(:card) }
      let(:object) { FactoryGirl.create(:cover_letter_task, card: card) }

      it "returns a serialized card" do
        do_request
        expect(response.status).to eq(200)
        expect(res_body).to include("card")
      end
    end

    context "resource is not answerable" do
      let(:object) { FactoryGirl.create(:user) }

      it "returns a 422" do
        do_request
        expect(response.status).to eq(422)
      end
    end
  end

  context "authentication" do
    let(:card) { FactoryGirl.create(:card) }
    let(:object) { FactoryGirl.create(:cover_letter_task, card: card) }

    it_behaves_like 'an unauthenticated json request'
  end
end
