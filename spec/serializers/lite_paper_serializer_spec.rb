require 'rails_helper'

describe LitePaperSerializer do
  subject(:serializer) { LitePaperSerializer.new(paper, user: user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create :paper }
  let(:serialized_content) { serializer.to_json }
  let(:deserialized_content) do
    JSON.parse(serialized_content, symbolize_names: true)
  end

  describe 'a paper' do
    it 'serializes successfully' do
      expect(deserialized_content[:lite_paper])
        .to match(hash_including(title: /Feature Recognition from 2D Hints in \
Extruded Solids/,
                                 publishing_state: 'unsubmitted',
                                 editable: true,
                                 active: true))
    end
  end

  describe 'a paper created by a user' do
    let(:paper) do
      FactoryGirl.create(:paper, :with_integration_journal, creator: user)
    end
    it "includes the 'My Paper' old_role" do
      expect(deserialized_content[:lite_paper])
        .to match(hash_including(old_roles: include('My Paper')))
    end
  end

  describe 'for a paper with multiple roles' do
    let(:early_date) { Time.now.utc - 10 }
    let(:later_date) { Time.now.utc }
    let!(:older_role) { FactoryGirl.create(:role, created_at: early_date) }
    let!(:newer_role) { FactoryGirl.create(:role, created_at: later_date) }

    before do
      paper.assignments.create!(user: user, role: older_role)
      paper.assignments.create!(user: user, role: newer_role)
    end

    it 'should use the latest role assignment date for the related_at_date' do
      expect(deserialized_content[:lite_paper])
        .to match(hash_including(related_at_date: later_date.as_json))
    end
  end
end
