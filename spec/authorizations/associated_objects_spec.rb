require 'rails_helper'

describe <<-DESC.strip_heredoc do
  In order to authorize an action on an object that the user is not
  directly assigned to the Authorization sub-system needs to be told what
  association methods could be used to look up that object.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:journal){ Authorizations::FakeJournal.create! }
  let!(:paper) { Authorizations::FakePaper.create!(fake_journal: journal) }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let!(:task_thing) { Authorizations::FakeTaskThing.create!(fake_task: task) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakePaper.name
    permission action: 'view', applies_to: Authorizations::FakeTask.name
    permission action: 'view', applies_to: Authorizations::FakeTaskThing.name
  end

  role :for_viewing do
    has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
    has_permission \
      action: 'view',
      applies_to: Authorizations::FakeTaskThing.name
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

      it 'denies the user access to tasks' do
        expect(user.can?(:view, task)).to be(false)
      end

      it 'denies the user access to task_things' do
        expect(user.can?(:view, task_thing)).to be(false)
      end

      it 'does not include the tasks when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTask.all).objects
        ).to eq([])
      end

      it 'does not include the tasks when filtering on the association' do
        expect(
          user.filter_authorized(:view, paper.fake_tasks).objects
        ).to eq([])
      end

      it 'does not include the task_things when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTaskThing.all).objects
        ).to eq([])
      end

      it 'does not include the task_things when filtering on the association' do
        expect(
          user.filter_authorized(:view, paper.fake_task_things).objects
        ).to eq([])
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

      it 'does not grant access to a model when the user the permssion on another model of the same type' do
        inaccessible_paper = Authorizations::FakeTask.create!(
          fake_journal: journal
        )
        expect(user.can?(:view, inaccessible_paper)).to be(false)
      end

      it 'includes the objects when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTask.all).objects
        ).to eq([task])
      end

      it 'includes the objects when filtering by the association' do
        expect(
          user.filter_authorized(:view, paper.fake_tasks).objects
        ).to eq([task])
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

      it 'includes those objects when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTaskThing.all).objects
        ).to eq([task_thing])
      end

      it 'includes those objects when filtering by the association' do
        expect(
          user.filter_authorized(:view, paper.fake_task_things).objects
        ).to eq([task_thing])
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

      it 'includes the object when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTaskThing.all).objects
        ).to eq([task_thing])
      end

      it 'includes those objects when filtering by the association' do
        expect(
          user.filter_authorized(:view, task.fake_task_thing).objects
        ).to eq([task_thing])
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

      it 'includes the object when filtering for authorization' do
        expect(
          user.filter_authorized(:view, Authorizations::FakeTask.all).objects
        ).to eq([task])
      end

      it 'includes the object when filtering by the association' do
        expect(
          user.filter_authorized(:view, task_thing.fake_task).objects
        ).to eq([task])
      end
    end

    context <<-DESC do
      when an inverse association is missing  definitions
    DESC
      let!(:association_options) do
        Authorizations::FakeTask.reflections['fake_paper'].options.dup
      end

      before do
        Authorizations.reset_configuration
        Authorizations.configure do |config|
          config.assignment_to(
            Authorizations::FakeTask,
            authorizes: Authorizations::FakePaper,
            via: :fake_paper
          )
        end
        assign_user user, to: task, with_role: role_for_viewing

        # Clear out any options (including inverse_of) that may exist
        Authorizations::FakeTask.reflections['fake_paper'].options.clear
      end

      after do
        Authorizations::FakeTask.reflections['fake_paper'].options.update(
          association_options
        )
      end

      it 'raises a CannotFindInverseAssociation' do
        expect {
          user.filter_authorized(:view, Authorizations::FakePaper.all).objects
        }.to raise_error(Authorizations::CannotFindInverseAssociation)
      end
    end
  end
end
