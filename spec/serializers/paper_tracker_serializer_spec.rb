require 'rails_helper'

describe PaperTrackerSerializer do
  include AuthorizationSpecHelper

  describe 'related_users' do
    let!(:paper) { FactoryGirl.create :paper }

    let!(:creator) { FactoryGirl.create :user }
    let!(:collaborator) { FactoryGirl.create :user }

    let(:roles) do
      serialized_paper = JSON.parse(
        PaperTrackerSerializer.new(paper).to_json,
        symbolize_names: true)
      serialized_paper[:paper_tracker][:related_users]
    end

    before do
      allow(paper).to receive(:participants_by_role).and_return(
        'Creator' => [creator],
        'Collaborator' => [collaborator]
      )
    end

    it 'returns an array of hashes contain the role name and user list' do
      creator_users = roles.find { |r| r[:name] == 'Creator' }[:users]
      expect(creator_users.first[:id]).to eq(creator.id)

      collaborator_users = roles.find { |r| r[:name] == 'Collaborator' }[:users]
      expect(collaborator_users.last[:id]).to eq(collaborator.id)
    end
  end
end
