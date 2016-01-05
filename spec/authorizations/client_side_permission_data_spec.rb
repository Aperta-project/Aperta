require 'rails_helper'

describe <<-DESC.strip_heredoc do
  In order to be able to communicate permission information to the front-end
  application the authorizations sub-system provides access to a
  stable Hash data format.
DESC
  include AuthorizationSpecHelper

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  before do
    Authorizations.configure do |config|
      config.assignment_to(
        Authorizations::FakeTask,
        authorizes: Authorizations::FakePaper,
        via: :fake_paper)
      config.assignment_to(
        Authorizations::FakeTask,
        authorizes: Journal,
        via: :journal)
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks)
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Journal,
        via: :journal)
      config.assignment_to(
        Journal,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks)
      config.assignment_to(
        Journal,
        authorizes: Authorizations::FakePaper,
        via: :fake_papers)
    end
  end

  after do
    Authorizations.reset_configuration
  end

  let!(:user) { FactoryGirl.create(:user, first_name: 'Bob Theuser') }
  let!(:journal) { FactoryGirl.create(:journal) }

  let!(:paper_assigned_to_journal) do
    Authorizations::FakePaper.create(journal: journal)
  end

  let!(:other_paper_on_same_journal) do
    Authorizations::FakePaper.create(journal: journal)
  end

  permissions do
    permission action: 'read', applies_to: Authorizations::FakePaper.name
    permission action: 'view', applies_to: Authorizations::FakePaper.name
    permission(
      action: 'write',
      applies_to: Authorizations::FakePaper.name,
      states: %w(in_progress))
    permission(
      action: 'talk',
      applies_to: Authorizations::FakePaper.name,
      states: %w(in_progress in_review))
  end

  role :editor do
    has_permission action: 'read', applies_to: Authorizations::FakePaper.name
    has_permission action: 'write', applies_to: Authorizations::FakePaper.name
    has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    has_permission action: 'talk', applies_to: Authorizations::FakePaper.name
  end

  before do
    assign_user user, to: paper_assigned_to_journal, with_role: role_editor
    assign_user user, to: other_paper_on_same_journal, with_role: role_editor
  end

  describe '#to_h' do
    it "returns a hash of all the user's permissions for the returned object" do
      results = user.enumerate_targets(:view, Authorizations::FakePaper.all)
      expect(results.to_h).to eq([
        {
          object: {
            id: paper_assigned_to_journal.id,
            type: Authorizations::FakePaper.name
          },
          permissions: {
            read: { states: %w(*) },
            write: { states: %w(in_progress) },
            view: { states: %w(*) },
            talk: { states: %w(in_progress in_review) }
          }
        },
        {
          object: {
            id: other_paper_on_same_journal.id,
            type: Authorizations::FakePaper.name
          },
          permissions: {
            read: { states: %w(*) },
            write: { states: %w(in_progress) },
            view: { states: %w(*) },
            talk: { states: %w(in_progress in_review) }
          }
        }
      ])
    end
  end
end
