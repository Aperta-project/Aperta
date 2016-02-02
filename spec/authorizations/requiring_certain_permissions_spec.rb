require 'rails_helper'

describe <<-DESC.strip_heredoc do
  Typically, if you have access to one kind of object (e.g. a Task) you have
  access to them all. However, there are times when you need to restrict
  access to certain objects (e.g. BillingTask).

  Any object that has one or more PermissionRequirement(s) can restrict
  access to that object to those specific permissions.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let!(:reserved_task) { Authorizations::FakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after do
    Authorizations.reset_configuration
  end

  permissions do
    permission(
      action: 'view',
      applies_to: Authorizations::FakeTask.name)
    permission(
      action: 'view_reserved_task',
      applies_to: Authorizations::FakeTask.name)
  end

  role :with_access_to_generic_tasks do
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  role :with_access_to_reserved_tasks do
    has_permission \
      action: 'view_reserved_task',
      applies_to: Authorizations::FakeTask.name
  end

  before do
    Authorizations.configure do |config|
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks
      )
    end
  end

  context <<-DESC do
    when a user has access to an object that has no required_permissions
  DESC

    before do
      expect(task.required_permissions.empty?).to be(true)
      assign_user user, to: paper, with_role: role_with_access_to_generic_tasks
    end

    it 'grants them access' do
      expect(user.can?(:view, task)).to be(true)
    end

    it 'includes all objects when filtering for authorization' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all).objects
      ).to include(task, reserved_task)
    end
  end

  context <<-DESC do
    when a user has access to an object that requires a specific permission
    they DO NOT HAVE
  DESC

    before do
      required_permission = Permission.find_by_action!('view_reserved_task')
      reserved_task.permission_requirements.create!(
        permission: required_permission
      )
      assign_user user, to: paper, with_role: role_with_access_to_generic_tasks
    end

    it 'grants them access' do
      expect(user.can?(:view_reserved_task, task)).to be(false)
    end

    it 'does not include objects that require the specific permission' do
      results = user.filter_authorized(
        :view_reserved_task,
        Authorizations::FakeTask.all)
      expect(results.objects).to_not include(reserved_task)
    end
  end

  context <<-DESC do
    when a user has access to an object that requires a specific permission
    that they DO HAVE
  DESC

    before do
      required_permission = Permission.find_by_action!('view_reserved_task')
      reserved_task.permission_requirements.create!(
        permission: required_permission
      )
      assign_user user, to: paper, with_role: role_with_access_to_reserved_tasks
    end

    it 'grants them access' do
      expect(user.can?(:view_reserved_task, reserved_task)).to be(true)
    end

    it 'includes the object that requires the specific permission' do
      results = user.filter_authorized(
        :view_reserved_task,
        Authorizations::FakeTask.all)
      expect(results.objects).to include(reserved_task)
    end
  end
end
