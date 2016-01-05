require 'rails_helper'

describe <<-DESC.strip_heredoc do
  It is possible for a user to get access to the same object thru multiple
  assignments. We only want to return the object ocne
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  role :with_access_to_task do
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  before do
    Authorizations.configure do |config|
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks)
    end
  end

  describe 'a user with access to an object thru multiple assignments' do
    before do
      assign_user user, to: paper, with_role: role_with_access_to_task
      assign_user user, to: task, with_role: role_with_access_to_task
    end

    it 'only returns the object once (no duplicates)' do
      expect(
        user.enumerate_targets(:view, Authorizations::FakeTask.all).objects
      ).to eq([task])
    end
  end

end
