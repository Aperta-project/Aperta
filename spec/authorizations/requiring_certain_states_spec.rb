require 'rails_helper'

describe <<-DESC.strip_heredoc do
  By default, permissions aren't tied to specific states, but they can be.

  Any object that implements a required_permission_id column and
  required_permission association can restrict access to a specific permission.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after do
    Authorizations.reset_configuration
  end

  permissions do
    permission(
      action: 'edit',
      applies_to: Authorizations::FakePaper.name,
      states: %w(unsubmitted in_revision)
    )
  end

  role :with_access_to_edit do
    has_permission action: 'edit', applies_to: Authorizations::FakePaper.name
  end

  context <<-DESC do
    when a user has access to an object that has requires a specific state
    BUT the object IS NOT IN that state
  DESC

    before do
      assign_user user, to: paper, with_role: role_with_access_to_edit
      paper.update! state: nil
    end

    it 'denies them access' do
      expect(user.can?(:edit, paper)).to be(false)
    end

    it 'does not include unauthorized objects' do
      expect(
        user.enumerate_targets(:edit, Authorizations::FakePaper.all).objects
      ).to_not include(paper)
    end
  end

  context <<-DESC do
    when a user has access to an object that has requires a specific state
    AND the object IS IN that state
  DESC
    before do
      assign_user user, to: paper, with_role: role_with_access_to_edit
      paper.update! state: 'unsubmitted'
    end

    it 'grants them access' do
      expect(user.can?(:edit, paper)).to be(true)
    end

    it 'includes authorized objects' do
      expect(
        user.enumerate_targets(:edit, Authorizations::FakePaper.all).objects
      ).to include(paper)
    end
  end

  context <<-DESC do
    when a user has access to an object through an association and it's
    in an permissible state
  DESC
    before do
      Authorizations.configure do |config|
        config.assignment_to(
          Authorizations::FakeTask,
          authorizes: Authorizations::FakePaper,
          via: :fake_paper
        )
      end

      assign_user user, to: task, with_role: role_with_access_to_edit
      paper.update! state: 'in_revision'
    end

    it 'grants them access' do
      expect(user.can?(:edit, paper)).to be(true)
    end

    it 'includes authorized objects' do
      expect(
        user.enumerate_targets(:edit, Authorizations::FakePaper.all).objects
      ).to include(paper)
    end
  end
end
