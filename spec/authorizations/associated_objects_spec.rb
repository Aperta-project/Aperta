require 'rails_helper'

describe <<-DESC.strip_heredoc do
  In order to authorize an action on an object that the user is not
  directly assigned to the Authorization sub-system needs to be told what
  association methods could be used to look up that object.
DESC
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { Authorizations::FakePaper.create! }
  let(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let(:task_thing) { Authorizations::FakeTaskThing.create!(fake_task: task) }

  permissions do
    permission action: 'view', applies_to: Authorizations::FakeTask.name
    permission action: 'view', applies_to: Authorizations::FakeTaskThing.name
  end

  role :for_viewing do
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
    has_permission \
      action: 'view',
      applies_to: Authorizations::FakeTaskThing.name
  end

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after do
    Authorizations.reset_configuration
  end

  context <<-DESC do
    when the user is assigned to an object with a role that grants them
    permission to view Task(s) and TaskThing(s)
  DESC

    context <<-DESC do
      BUT authorizations aren't configured to tell the authorization sub-system
      how to look up these objects
    DESC

      before do
        assign_user user, to: paper, with_role: role_for_viewing
      end

      it 'denies the user access' do
        expect(user.can?(:view, task)).to be(false)
        expect(user.can?(:view, task_thing)).to be(false)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_MANY association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(
            Authorizations::FakePaper,
            authorizes: Authorizations::FakeTask,
            via: :fake_tasks
          )
        end
        assign_user user, to: paper, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, task)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_ONE association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(
            Authorizations::FakeTask,
            authorizes: Authorizations::FakeTaskThing,
            via: :fake_task_thing
          )
        end
        assign_user user, to: task, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, task_thing)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      BELONGS_TO association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(
            Authorizations::FakeTaskThing,
            authorizes: Authorizations::FakeTask,
            via: :fake_task
          )
        end
        assign_user user, to: task_thing, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, task)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_MANY :THROUGH association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(
            Authorizations::FakePaper,
            authorizes: Authorizations::FakeTaskThing,
            via: :fake_task_things
          )
        end
        assign_user user, to: paper, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, task_thing)).to be(true)
      end
    end
  end
end
