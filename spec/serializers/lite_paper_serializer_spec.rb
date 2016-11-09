require 'rails_helper'

describe LitePaperSerializer do
  subject(:serializer) { described_class.new(paper, user: user, root: :paper) }
  let(:paper) { FactoryGirl.build_stubbed(Paper) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

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
    let(:paper) do
      FactoryGirl.create(:paper, :with_integration_journal, creator: user)
    end
    it "includes the 'My Paper' role" do
      expect(deserialized_content[:lite_paper])
        .to match(hash_including(roles: include('My Paper')))
    end

    describe 'old_roles' do
      let!(:one_day_ago) { 1.day.ago }
      let!(:two_days_ago) { 2.days.ago }

      context 'when the user has role descriptions on this paper' do
        before do
          allow(paper).to receive(:role_descriptions_for)
            .with(user: user)
            .and_return ['Author', 'Collaborator']
        end

        it "serializes those descriptions" do
          expect(json[:old_roles]).to contain_exactly('Author', 'Collaborator')
        end
      end

      context 'when there is no user' do
        subject(:serializer) { described_class.new(paper, user: nil, root: :paper) }

        it 'is serialized as nil' do
          expect(json).to match hash_including(old_roles: nil)
        end
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
        subject(:serializer) { described_class.new(paper, user: nil, root: :paper) }

        it 'is serialized as nil' do
          expect(json).to match hash_including(related_at_date: nil)
        end
      end
    end
  end
end
