require 'rails_helper'

describe LitePaperSerializer do
  subject(:serializer) do
    described_class.new(paper, user: user, root: :paper).tap do |serializer|
      # The :current_user method is provided by the controller when responding
      # to a request as it includes the ActionController::Serialization
      # module into each serializer with a serialization_scope of
      # :current_user. We need to make #current_user available for this
      # test.
      _current_user = current_user
      serializer.send :define_singleton_method, :current_user do
        _current_user
      end
    end
  end

  let(:paper) { FactoryGirl.build_stubbed(Paper) }
  let!(:user) { FactoryGirl.build_stubbed(:user) }
  let(:current_user) { FactoryGirl.build_stubbed(:user) }

  before do
    allow(paper).to receive_messages(
      active: true,
      created_at: 'created_at_date',
      editable: true,
      id: 99,
      journal_id: 117,
      manuscript_id: 'doi.111',
      processing: true,
      publishing_state: 'unsubmitted',
      role_descriptions_for: [],
      title: 'The great paper'
    )
  end

  describe 'a paper created by a user' do
    let(:json) { serializer.as_json[:paper] }

    let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }

    let(:paper) do
      FactoryGirl.create(:paper, journal: journal, creator: user, preprint_doi_article_number: "1234567")
    end

    describe 'aarx_doi' do
      it "should be present" do
        expect(json[:aarx_doi].to_s).to be_present
      end
    end

    describe 'related_at_date' do
      let!(:one_day_ago) { 1.day.ago }
      let!(:two_days_ago) { 2.days.ago }

      context 'when the user has been assigned to this paper' do
        before do
          allow(paper).to receive(:roles_for)
            .with(user: user)
            .and_return [double(created_at: one_day_ago), double(created_at: two_days_ago)]
        end

        it "serializes to the user's latest role assignment to this paper" do
          expect(json[:related_at_date].to_s).to eq(one_day_ago.to_s)
        end
      end

      context 'when the use has not been assigned to this paper' do
        before do
          allow(paper).to receive(:roles_for)
            .with(user: user)
            .and_return []
        end

        it "serializes to nil" do
          expect(json).to match hash_including(related_at_date: nil)
        end
      end

      context 'when there is no user' do
        subject(:serializer) do
          described_class.new(paper, user: nil, root: :paper).tap do |serializer|
            _current_user = current_user
            serializer.send :define_singleton_method, :current_user do
              _current_user
            end
          end
        end

        it 'is serialized as nil' do
          expect(json).to match hash_including(related_at_date: nil)
        end
      end
    end

    describe '#preprint_dashboard' do
      let(:author) { FactoryGirl.build_stubbed(:author) }

      before do
        allow(paper).to receive(:authors) { [author] }
      end

      it 'returns true if current user also and author of the paper' do
        allow(author).to receive(:user_id) { current_user.id }
        expect(json[:preprint_dashboard]).to be_truthy
      end

      it 'returns false if current user is not an author of the paper' do
        allow(author).to receive(:user_id) { user.id }
        expect(json[:preprint_dashboard]).to be_falsey
      end
    end
  end
end
