require 'rails_helper'

describe PaperTrackerSerializer do
  include AuthorizationSpecHelper

  describe 'related_users' do
    let!(:creator) { FactoryGirl.create :user }
    let!(:paper) { FactoryGirl.create :paper, creator: creator }
    let!(:journal) { paper.journal }
    let!(:collaborator) { FactoryGirl.create :user }
    let!(:internal_editor) { FactoryGirl.create :user }
    let!(:reviewer) { FactoryGirl.create :user }

    let(:roles) do
      serialized_paper = JSON.parse(
        PaperTrackerSerializer.new(paper).to_json,
        symbolize_names: true)
      serialized_paper[:paper_tracker][:related_users]
    end

    before do
      # Ensure the roles are scoped to the paper's journal
      Role.ensure_exists('Creator', journal: journal)
      Role.ensure_exists('Internal Editor', journal: journal)
      Role.ensure_exists('Reviewer', journal: journal)
      Role.ensure_exists('Collaborator', journal: journal)

      roles = paper.journal.roles
      assign_user collaborator, to: paper, with_role: roles.collaborator
      assign_user internal_editor, to: paper, with_role: roles.internal_editor
      assign_user reviewer, to: paper, with_role: roles.reviewer
    end

    it 'lists the author' do
      authors = roles.find { |r| r[:name] == 'Creator' }[:users]
      expect(authors[0][:id]).to be(creator.id)
    end

    it 'lists the collaborators' do
      collaborators = roles.find { |r| r[:name] == 'Collaborator' }[:users]
      expect(collaborators[0][:id]).to be(collaborator.id)
    end

    it 'lists the reviewer' do
      reviewers = roles.find { |r| r[:name] == 'Reviewer' }[:users]
      expect(reviewers[0][:id]).to be(reviewer.id)
    end

    it 'lists the internal_editor' do
      internal_editors = roles.find { |r| r[:name] == 'Internal Editor' }[:users]
      expect(internal_editors[0][:id]).to be(internal_editor.id)
    end
  end
end
