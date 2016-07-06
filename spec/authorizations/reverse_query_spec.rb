require 'rails_helper'

describe <<-DESC.strip_heredoc do
  The possible ways to find people that have permissions on authorized objects
DESC
  include AuthorizationSpecHelper

  let!(:author_user) { FactoryGirl.create(:user) }
  let!(:admin_user) { FactoryGirl.create(:user) }
  let!(:other_user) { FactoryGirl.create(:user) }
  let!(:journal) { Authorizations::FakeJournal.create!(name: 'The Journal') }
  let!(:paper) { Authorizations::FakePaper.create!(fake_journal: journal) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  after :all do
    Authorizations.reset_configuration
  end

  context 'an assignment which is assigned directly to the object in question' do
    permissions do
      permission action: 'view', applies_to: Authorizations::FakePaper.name
    end

    role :paper_viewer do
      has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    end

    before do
      assign_user author_user, to: paper, with_role: role_paper_viewer
    end

    describe Authorizations::ReverseQuery do
      subject(:reverse_query) do
        Authorizations::ReverseQuery.new(permission: :view, target: paper)
      end

      describe '#authorizations_on_target' do
        subject { reverse_query.authorizations_on_target(paper) }
        it { is_expected.to be_empty }
      end

      describe '#models_which_authorize' do
        subject { reverse_query.models_which_authorize(paper) }
        it { is_expected.to be_empty }
      end

      describe '#users_assigned_directly_to' do
        subject { reverse_query.users_assigned_directly_to(paper) }
        it { is_expected.to eq [author_user] }
      end

      describe '#users_authorized_through_parents_of' do
        subject { reverse_query.users_authorized_through_parents_of(paper) }
        it { is_expected.to be_empty }
      end

      describe '#users_with_access_to' do
        subject { reverse_query.users_with_access_to(paper) }
        it { is_expected.to eq [author_user] }
      end
    end

    describe 'User::who_can' do
      it 'returns people who can do a particular action to a thing' do
        expect(author_user.can?(:view, paper)).to eq true
        expect(other_user.can?(:view, paper)).to eq false
        users = User.who_can(:view, paper)
        expect(users).to match [author_user]
      end
    end
  end

  context 'an assignment which authorizes the object in question' do
    permissions do
      permission action: 'delete', applies_to: Authorizations::FakePaper.name
    end

    role :journal_admin do
      has_permission action: 'delete', applies_to: Authorizations::FakePaper.name
    end

    before :all do
      Authorizations.configure do |config|
        config.assignment_to(
          Authorizations::FakeJournal,
          authorizes: Authorizations::FakePaper,
          via: :fake_papers
        )
      end
    end

    after :all do
      Authorizations.reset_configuration
    end

    before :each do
      assign_user admin_user, to: journal, with_role: role_journal_admin
    end

    describe Authorizations::ReverseQuery do
      subject(:reverse_query) do
        Authorizations::ReverseQuery.new(permission: :delete, target: paper)
      end

      describe '#authorizations_on_target' do
        subject { reverse_query.authorizations_on_target(paper) }
        it { is_expected.to eq Authorizations.configuration.authorizations }
      end

      describe '#models_which_authorize' do
        subject { reverse_query.models_which_authorize(paper) }
        it { is_expected.to eq [journal] }
      end

      describe '#users_assigned_directly_to' do
        subject { reverse_query.users_assigned_directly_to(paper) }
        it { is_expected.to be_empty }
      end

      describe '#users_authorized_through_parents_of' do
        subject { reverse_query.users_authorized_through_parents_of(paper) }
        it { is_expected.to eq [admin_user] }
      end

      describe '#users_with_access_to' do
        subject { reverse_query.users_with_access_to(paper) }
        it { is_expected.to eq [admin_user] }
      end
    end

    describe 'User::who_can' do
      it 'returns people who can do a particular action to a thing' do
        expect(admin_user.can?(:delete, paper)).to eq true
        users = User.who_can(:delete, paper)
        expect(users).to match [admin_user]
      end
    end
  end
end
