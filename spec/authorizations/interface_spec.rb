require 'rails_helper'

describe <<-DESC.strip_heredoc do
  The possible ways to check permissions and filter authorized objects.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create!(name: 'Bar Paper') }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let!(:task_thing) { Authorizations::FakeTaskThing.create!(fake_task: task) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakePaper.name
    permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  role :for_viewing do
    has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

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

  after do
    Authorizations.reset_configuration
  end

  context <<-DESC do
    #can? - Checking authorizing for a specific model
  DESC

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'can filter authorized models when given a class (least performant)' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper).objects
      ).to eq([paper])
    end
  end


    it 'can filter authorized models when given a ActiveRecord::Relation' do
  context <<-DESC do
    #filter_authorized - filtering objects with authorization when the user
    is assigned directly to the kind of object they trying to access
  DESC

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'can filter authorized models when given a simple ActiveRecord::Relation' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.all).objects
      ).to eq([paper])
    end

    it 'can filter authorized models given an ActiveRecord::Relation with conditions' do
      query = Authorizations::FakePaper

      inclusion_query = query.where(id: paper.id)
      expect(
        user.filter_authorized(:view, inclusion_query).objects
      ).to eq([paper])

      exclusion_query = query.where('id != ?', paper.id)
      expect(
        user.filter_authorized(:view, exclusion_query).objects
      ).to_not include(paper)
    end

    it 'can filter authorized models given where-chained ActiveRecord::Relation(s)' do
      query = Authorizations::FakePaper

      chained_inclusion_query = query.where(id: paper.id).where(name: paper.name)
      expect(
        user.filter_authorized(:view, chained_inclusion_query).objects
      ).to include(paper)

      chained_exclusion_query = query.where(id: paper.id).where('name != ?', paper.name)
      expect(
        user.filter_authorized(:view, chained_exclusion_query).objects
      ).to_not include(paper)
    end

    it 'can filter authorized models given joined-chained ActiveRecord::Relation(s)' do
      query = Authorizations::FakePaper

      inclusion_query = query.joins(:fake_tasks).where(fake_tasks: { id: task.id })
      expect(
        user.filter_authorized(:view, inclusion_query).objects
      ).to include(paper)

      exclusion_query = query.joins(:fake_tasks)
        .where(fake_tasks: { id: task.id + 1000 })
      expect(
        user.filter_authorized(:view, exclusion_query).objects
      ).to_not include(paper)
    end
  end
end
