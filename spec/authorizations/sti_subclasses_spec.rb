require 'rails_helper'

describe <<-DESC.strip_heredoc do
  In order to authorize an action on an object that the user is not
  directly assigned to the Authorization sub-system needs to be told what
  association methods could be used to look up that object.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:generic_task) { Authorizations::FakeTask.create!(fake_paper: paper) }
  let!(:specialized_task) { Authorizations::SpecializedFakeTask.create!(fake_paper: paper) }
  let!(:even_more_specialized_task) { Authorizations::EvenMoreSpecializedFakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after do
    Authorizations.reset_configuration
  end

  context 'when you have permissions to an ancestor' do
    permissions do
      permission action: 'view', applies_to: Authorizations::FakeTask.name
    end

    role :for_viewing do
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

    it 'grants access to a subclass' do
      expect(user.can?(:view, specialized_task)).to be(true)
    end

    it 'grants access to a descendant (subclass of a subclass and so on)' do
      expect(user.can?(:view, even_more_specialized_task)).to be(true)
    end

    it 'includes the descendnant objects when filtering for authorization of the parent class' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all).objects
      ).to contain_exactly(generic_task, specialized_task, even_more_specialized_task)
    end

    it 'includes the only subclass objects and its descendants when filtering for authorization of the subclass' do
      expect(
        user.filter_authorized(:view, Authorizations::SpecializedFakeTask.all).objects
      ).to contain_exactly(specialized_task, even_more_specialized_task)

      expect(
        user.filter_authorized(:view, Authorizations::EvenMoreSpecializedFakeTask.all).objects
      ).to contain_exactly(even_more_specialized_task)
    end
  end
end
