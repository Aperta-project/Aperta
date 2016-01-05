require 'rails_helper'

describe <<-DESC.strip_heredoc do
  In order to authorize an action on an object that the user is not
  directly assigned to the Authorization sub-system needs to be told what
  association methods could be used to look up that object.
DESC
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create(:user) }
  let(:fake_paper) { FakePaper.create! }
  let(:fake_task) { FakeTask.create!(fake_paper: fake_paper) }
  let(:fake_task_thing) { FakeTaskThing.create!(fake_task: fake_task) }

  permissions do
    permission action: 'view', applies_to: FakeTask.name
    permission action: 'view', applies_to: FakeTaskThing.name
  end

  role :for_viewing do
    has_permission action: 'view', applies_to: FakeTask.name
    has_permission action: 'view', applies_to: FakeTaskThing.name
  end

  before(:all) do
    Authorizations.reset_configuration

    # Set-up some dummy tables in our test database specificially
    # for our tests here
    ActiveRecord::Schema.define do
      create_table :fake_papers, force: true do |t|
      end

      create_table :fake_tasks, force: true do |t|
        t.integer :fake_paper_id
      end

      create_table :fake_task_things, force: true do |t|
        t.integer :fake_task_id
      end
    end
  end

  ####################################################################
  # NOTE: These models exist to avoid conflicting with real application
  # models. This is so this functionality can be tested in isolation
  # regardless of how the real app models change over time.
  ####################################################################
  class FakePaper < ActiveRecord::Base
    has_many :fake_tasks
    has_many :fake_task_things, through: :fake_tasks
  end

  class FakeTask < ActiveRecord::Base
    belongs_to :fake_paper
    has_one :fake_task_thing
  end

  class FakeTaskThing < ActiveRecord::Base
    belongs_to :fake_task
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
        assign_user user, to: fake_paper, with_role: role_for_viewing
      end

      it 'denies the user access' do
        expect(user.can?(:view, fake_task)).to be(false)
        expect(user.can?(:view, fake_task_thing)).to be(false)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_MANY association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(FakePaper, authorizes: FakeTask, via: :fake_tasks)
        end
        assign_user user, to: fake_paper, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, fake_task)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_ONE association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(FakeTask, authorizes: FakeTaskThing, via: :fake_task_thing)
        end
        assign_user user, to: fake_task, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, fake_task_thing)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      BELONGS_TO association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(FakeTaskThing, authorizes: FakeTask, via: :fake_task)
        end
        assign_user user, to: fake_task_thing, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, fake_task)).to be(true)
      end
    end

    context <<-DESC do
      and authorizations ARE configured to look up objects through a
      HAS_MANY :THROUGH association
    DESC
      before do
        Authorizations.configure do |config|
          config.assignment_to(FakePaper, authorizes: FakeTaskThing, via: :fake_task_things)
        end
        assign_user user, to: fake_paper, with_role: role_for_viewing
      end

      it 'grants them access' do
        expect(user.can?(:view, fake_task_thing)).to be(true)
      end
    end

  end
end
