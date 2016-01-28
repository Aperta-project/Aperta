require 'rails_helper'

describe <<-DESC.strip_heredoc do
  There are two kinds of visibility that pertain to the authorization
  sub-system:

    1) participating objects - these are the objects a user is considered
      to be actively participating in.

    2) accessible objects - these are the objects that a user has the
      authority to access, but that likely won't show up by default. E.g. a
      journal admin has access to all papers in the journal, but it probably
      doesn't make sense to populate their dashboard with all of them.

  Columns can be added to the roles table that provide hints to the
  authorization sub-system about what kinds of objects to include. The
  naming convention for each hinting column is:

     'participates_in_' + YourModel.table_name
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:journal) { Authorizations::FakeJournal.create! }
  let!(:paper) { Authorizations::FakePaper.create!(fake_journal: journal) }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper) }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  before(:each) do
    ActiveRecord::Schema.define do
      add_column(
        :roles,
        :participates_in_fake_papers,
        :boolean,
        null: false,
        default: false
      )
    end
    Role.reset_column_information
  end

  after(:each) do
    ActiveRecord::Schema.define do
      remove_column :roles, :participates_in_fake_papers
    end
    Role.reset_column_information
  end

  permissions do
    permission action: 'view', applies_to: Authorizations::FakePaper.name
    permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  role :author do
    has_permission action: 'view', applies_to: Authorizations::FakePaper.name
    has_permission action: 'view', applies_to: Authorizations::FakeTask.name
  end

  before do
    Authorizations.configure do |config|
      config.assignment_to(
        Authorizations::FakeJournal,
        authorizes: Authorizations::FakePaper,
        via: :fake_papers
      )
      config.assignment_to(
        Authorizations::FakePaper,
        authorizes: Authorizations::FakeTask,
        via: :fake_tasks
      )
    end
  end

  after do
    Authorizations.reset_configuration
  end

  context <<-DESC do
    when a user has access to an object that DOES NOT provide a hint column
    indicating they are participating in a kind of object
  DESC

    before do
      assign_user user, to: paper, with_role: role_author
      expect(Authorizations::FakeTask.column_names).to_not \
        include('participates_in_fake_tasks')
    end

    it 'grants them access' do
      expect(user.can?(:view, paper)).to be(true)
    end

    it 'includes the paper when filtering for authorization' do
      expect(
        user.filter_authorized(:view, Authorizations::FakeTask.all).objects
      ).to include(task)
    end
  end

  context <<-DESC do
    when a user has access to an object that DOES provide a hint column
    indicating they are participating in a kind of object BUT the value
    is FALSE
  DESC

    let(:participations_only) { :default }
    let(:filtered) do
      user.filter_authorized(:view, target,
                             participations_only: participations_only).objects
    end

    before do
      assign_user user, to: paper, with_role: role_author
      expect(Authorizations::FakePaper.column_names).to_not \
        include('participates_in_fake_papers')
      role_author.update! participates_in_fake_papers: false
    end

    context 'and the user is assigned directly to the target' do
      before do
        expect(user.assignments.where(assigned_to: paper).first).to be
      end

      it 'grants them access' do
        expect(user.can?(:view, paper)).to be(true)
      end
    end

    context 'and the user is not assigned directly to the target' do
      before do
        user.assignments.destroy_all
        expect(user.assignments.where(assigned_to: paper).first).to_not be
        assign_user user, to: journal, with_role: role_author
      end

      it 'grants them access' do
        expect(user.can?(:view, paper)).to be(true)
      end
    end

    context 'ActiveRecord::Base class passed in as target' do
      let(:target) { Authorizations::FakePaper }

      it 'does not include the paper when filtering for authorization' do
        expect(filtered).to_not include(paper)
      end

      context 'participations_only overridden (=false)' do
        let(:participations_only) { false }
        it 'includes the paper when filtering for authorization' do
          expect(filtered).to include(paper)
        end
      end
    end

    context 'ActiveRecord::Relation passed in as target' do
      let(:target) { Authorizations::FakePaper.all }

      it 'does not includes the paper when filtering for authorization' do
        expect(filtered).to_not include(paper)
      end

      context 'participations_only overridden (=false)' do
        let(:participations_only) { false }
        it 'includes the paper when filtering for authorization' do
          expect(filtered).to include(paper)
        end
      end
    end

    context 'ActiveRecord::Base instance passed in as target' do
      let(:target) { paper }

      it 'includes the paper when filtering for authorization by default' do
        expect(filtered).to include(paper)
      end

      context 'participations_only overridden (=true)' do
        let(:participations_only) { true }
        it 'does not include the paper when filtering for authorization' do
          expect(filtered).to_not include(paper)
        end
      end
    end
  end

  context <<-DESC do
    when a user has access to an object that DOES provide a hint column
    indicating they are participating in a kind of object AND the value
    is TRUE
  DESC

    before do
      assign_user user, to: paper, with_role: role_author
      expect(Authorizations::FakePaper.column_names).to_not \
        include('participates_in_fake_papers')
      role_author.update! participates_in_fake_papers: true
    end

    it 'grants them access' do
      expect(user.can?(:view, paper)).to be(true)
    end

    it 'includes the paper when filtering for authorization' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.all).objects
      ).to include(paper)
    end

    it 'includes the paper when filtering for authorization if
        participates_only is set to true or false' do
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.all,
                               participations_only: false).objects
      ).to include(paper)
      expect(
        user.filter_authorized(:view, Authorizations::FakePaper.all,
                               participations_only: true).objects
      ).to include(paper)
    end
  end
end
