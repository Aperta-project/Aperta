require 'rails_helper'

describe 'Authorizations for objects a user is directly assigned to' do
  include AuthorizationSpecHelper

  before do
    Authorizations.configure do |config|
      # TODO: it seems that you automatically get access to objects you're
      # assigned to as long as the permission has an applies_to for that kind
      # of object. Need to check with Erik if this is intentional or if it
      # was an oversight on our part. My default assumption was that this
      # set of examples would fail without a line of configuration providing
      # access to papers, but I'm not sure.
    end
  end

  after do
    Authorizations.reset_configuration
  end

  let!(:user) { FactoryGirl.create(:user, first_name: 'User') }
  let!(:other_user) { FactoryGirl.create(:user, first_name: 'Other User') }

  let!(:paper) { FactoryGirl.create(:paper, title: 'User paper') }
  let!(:other_user_paper) { FactoryGirl.create(:paper, title: 'Other User paper') }

  permissions do
    permission action: 'view', applies_to: Paper.name
    permission action: 'edit', applies_to: Paper.name
    permission action: 'whatever', applies_to: Paper.name

    permission action: 'view', applies_to: 'SomethingThatIsNotAPaper'
    permission action: 'edit', applies_to: 'SomethingThatIsNotAPaper'
    permission action: 'whatever', applies_to: 'SomethingThatIsNotAPaper'
  end

  role :with_access_to_paper do
    has_permission action: 'view', applies_to: Paper.name
    has_permission action: 'edit', applies_to: Paper.name
    has_permission action: 'whatever', applies_to: Paper.name
  end

  role :with_no_access_to_paper do
    has_permission action: 'view', applies_to: 'SomethingThatIsNotAPaper'
    has_permission action: 'edit', applies_to: 'SomethingThatIsNotAPaper'
    has_permission action: 'whatever', applies_to: 'SomethingThatIsNotAPaper'
  end

  context 'when Authorizations is not configured for access' do
    it 'always denies access since configuration must be explicit' do
      # TODO: implement if this is correct? or delete?
    end

    it 'allows access when the object a user is assigned to matches the permissions applies_to' do
      # TODO: implement if this is correct? or delete?
    end
  end

  context 'when user is assigned to an object (e.g. Paper)' do
    context 'with a role that has permissions that apply to that kind of object (e.g. Paper)' do
      before do
        assign_user user, to: paper, with_role: role_with_access_to_paper
        assign_user other_user, to: other_user_paper, with_role: role_with_access_to_paper
      end

      it 'authorizes access for their permissions for the object they are assigned to' do
        expect(user.can?(:view, paper)).to be(true)
        expect(user.can?(:edit, paper)).to be(true)
        expect(user.can?(:whatever, paper)).to be(true)

        expect(other_user.can?(:view, other_user_paper)).to be(true)
        expect(other_user.can?(:edit, other_user_paper)).to be(true)
        expect(other_user.can?(:whatever, other_user_paper)).to be(true)
      end

      it 'denies them access to a different object of the same kind (e.g. Someone elses paper)' do
        expect(user.can?(:view, other_user_paper)).to be(false)
        expect(user.can?(:edit, other_user_paper)).to be(false)
        expect(user.can?(:whatever, other_user_paper)).to be(false)
      end
    end

    context 'with a role that lacks permissions for that kind of object (e.g. No permission that applies_to Paper)' do
      before do
        assign_user user, to: paper, with_role: role_with_no_access_to_paper
      end

      it 'denies them access to the object they are assigned to' do
        expect(user.can?(:view, paper)).to be(false)
        expect(user.can?(:edit, paper)).to be(false)
        expect(user.can?(:whatever, paper)).to be(false)
      end
    end
  end
end
