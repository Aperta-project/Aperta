require 'rails_helper'

describe PaperTrackerSerializer do
  include AuthorizationSpecHelper

  describe 'related_users' do
    let!(:paper) { FactoryGirl.build_stubbed :paper  }
    let!(:creator) { FactoryGirl.build_stubbed :user }
    let!(:collaborator) { FactoryGirl.build_stubbed :user }
    let!(:cover_editor) { FactoryGirl.build_stubbed :user }
    let!(:handling_editor) { FactoryGirl.build_stubbed :user }

    let(:roles) do
      serialized_paper = JSON.parse(
        PaperTrackerSerializer.new(paper).to_json,
        symbolize_names: true)
      serialized_paper[:paper_tracker][:related_users]
    end

    before do
      allow(paper).to receive(:cover_editors).and_return([cover_editor])
      allow(paper).to receive(:handling_editors).and_return([handling_editor])

      allow(paper).to receive(:participants_by_role).and_return(
        'Creator' => [creator],
        'Collaborator' => [collaborator],
        'Cover Editor' => [cover_editor],
        'Handling Editor' => [handling_editor]
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
