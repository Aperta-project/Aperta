require 'rails_helper'

describe <<-DESC.strip_heredoc do
  The possible ways to check permissions and filter authorized objects.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
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
    Authorization can be checked when passing in a specific model
  DESC

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'can filter authorized models when given a class (least performant)' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper).objects
      ).to eq([paper])
    end

    it 'can filter authorized models when given a ActiveRecord::Relation' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.all).objects
      ).to eq([paper])
    end

    it 'can filter authorized models respecting chained AR Relation(s)' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.where(id: paper.id)).objects
      ).to eq([paper])

      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.where('id != ?', paper.id)).objects
      ).to_not include(paper)
    end
  end
end
