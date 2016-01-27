require 'rails_helper'

describe <<-DESC.strip_heredoc do
  The possible ways to check permissions and filter authorized objects.
DESC
  include AuthorizationSpecHelper

  let!(:user) { FactoryGirl.create(:user) }
  let!(:journal){ Authorizations::FakeJournal.create!(name: 'The Journal') }
  let!(:paper) { Authorizations::FakePaper.create!(name: 'Bar Paper', fake_journal: journal) }
  let!(:other_paper) { Authorizations::FakePaper.create!(name: 'Other Paper') }
  let!(:task) { Authorizations::FakeTask.create!(fake_paper: paper, name: 'Foo Task') }
  let!(:other_task) { Authorizations::FakeTask.create!(fake_paper: other_paper, name: 'Other Task') }
  let!(:task_thing) { Authorizations::FakeTaskThing.create!(fake_task: task) }
  let!(:other_task_thing) { Authorizations::FakeTaskThing.create!(fake_task: task) }
  let(:task_json) do
    [object:
       { id: task.id,
         type: 'Authorizations::FakeTask' },
     permissions: { view: { states: ['*'] } }]
  end

  let(:paper_json) do
    [object:
       { id: paper.id,
         type: 'Authorizations::FakePaper' },
     permissions: { view: { states: ['*'] } }]
  end

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
    let(:filtered) { user.filter_authorized(:view, Authorizations::FakePaper) }

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    it 'returns false when the user does not have permission to the object' do
      expect(user.can?(:view, journal)).to be(false)
    end

    it 'returns true when the user has permission to the object' do
      expect(user.can?(:view, paper)).to be(true)
    end

    it 'can filter authorized models when given a class (least performant)' do
      expect(filtered.objects).to eq([paper])
    end

    it 'does not include unauthorized items' do
      expect(filtered.objects).to_not include(other_paper)
    end

    it 'generates the correct json' do
      expect(filtered.as_json).to eq(paper_json)
    end
  end

  context <<-DESC do
    #filter_authorized - filtering objects with authorization when the user
    is NOT directly assigned to the kind of object they trying to access
  DESC

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    context 'when given a simple ActiveRecord::Relation' do
      let(:filtered) do
        user.filter_authorized(:view, Authorizations::FakeTask.all)
      end

      it 'can filter authorized models' do
        expect(filtered.objects).to eq(paper.fake_tasks)
      end

      it 'does not include unauthorized items' do
        expect(filtered.objects).to_not include(other_task)
      end

      it 'generates the correct json' do
        expect(filtered.as_json).to eq(task_json)
      end
    end

    context 'when given an ActiveRecord::Relation with conditions' do
      let(:filtered) do
        user.filter_authorized(:view, query)
      end
      let(:query) { Authorizations::FakeTask.all }

      it 'can filter authorized models given an ActiveRecord::Relation with conditions' do
        expect(filtered.objects).to eq([task])
      end

      it 'does not include unauthorized items' do
        expect(
          user.filter_authorized(:view, query.where.not(id: task.id)).objects
        ).to_not include(task)
      end

      it 'generates the correct json' do
        expect(filtered.as_json).to eq(task_json)
      end
    end

    context 'when given where-chained ActiveRecord::Relation(s)' do
      let(:query) { Authorizations::FakeTask.all }

      it 'can filter authorized models' do
        chained_inclusion_query = query.where(id: task.id).where(name: task.name)
        expect(
          user.filter_authorized(:view, chained_inclusion_query).objects
        ).to include(task)
      end

      it 'does not include unauthorized items' do
        chained_query = query.where(id: other_paper.id).where(name: other_task.name)
        expect(
          user.filter_authorized(:view, chained_query).objects
        ).to_not include(other_task)
      end

      it 'raises when the column name is ambiguous' do
        chained_exclusion_query = query.where(id: paper.id).where('name = ?', paper.name)
        expect do
          user.filter_authorized(:view, chained_exclusion_query).objects
        end.to raise_error(/column reference "name" is ambiguous/)
      end
    end

    context 'when given join-chained ActiveRecord::Relation(s)' do
      let(:query) { Authorizations::FakeTask.all }

      it 'can filter authorized models' do
        inclusion_query = query.joins(:fake_task_thing).where(fake_task_things: { id: task_thing.id })
        expect(
          user.filter_authorized(:view, inclusion_query).objects
        ).to include(task)

        exclusion_query = query.joins(:fake_task_thing)
          .where(fake_task_things: { id: task_thing.id + 1000 })
        expect(
          user.filter_authorized(:view, exclusion_query).objects
        ).to_not include(task)
      end

      it 'can filter authorized models with joins thru a :through join' do
        inclusion_query = query.joins(:fake_journal).where('fake_journals.id' => journal.id)
        expect(
          user.filter_authorized(:view, inclusion_query).objects
        ).to include(task)
      end

      it 'can filter authorized models with complex joins' do
        inclusion_query = query.joins(fake_paper: :fake_journal).where('fake_journals.id' => journal.id)
        expect(
          user.filter_authorized(:view, inclusion_query).objects
        ).to include(task)
      end

      it 'does not include unauthorized models' do
        unauthorized_query = query.joins(:fake_task_thing)
          .where(fake_task_things: { id: other_task_thing.id })
        expect(
          user.filter_authorized(:view, unauthorized_query).objects
        ).to_not include(other_task)
      end
    end
  end

  context <<-DESC do
    #filter_authorized - filtering objects with authorization when the user
    is assigned directly to the kind of object they trying to access
  DESC

    before do
      assign_user user, to: paper, with_role: role_for_viewing
    end

    context 'when given a simple ActiveRecord::Relation' do
      it 'can filter authorized models' do
        expect(
          user.filter_authorized(:view, Authorizations::FakePaper.all).objects
        ).to eq([paper])
      end

      it 'does not include unauthorized models' do
        expect(
          user.filter_authorized(:view, Authorizations::FakePaper.all).objects
        ).to_not include(other_paper)
      end
    end

    context 'when given an ActiveRecord::Relation with conditions' do
      let(:query) { Authorizations::FakePaper.all }

      it 'can filter authorized models' do
        inclusion_query = query.where(id: paper.id)
        expect(
          user.filter_authorized(:view, inclusion_query).objects
        ).to eq([paper])

        exclusion_query = query.where.not(id: paper.id)
        expect(
          user.filter_authorized(:view, exclusion_query).objects
        ).to_not include(paper)
      end

      it 'does not include unauthorized models' do
        unauthorized_query = query.where(id: other_paper.id)
        expect(
          user.filter_authorized(:view, unauthorized_query).objects
        ).to_not include(other_paper)
      end
    end

    context 'when given where-chained ActiveRecord::Relation(s)' do
      let(:query) { Authorizations::FakePaper.all }

      it 'can filter authorized models ' do
        chained_inclusion_query = query.where(id: paper.id).where(name: paper.name)
        expect(
          user.filter_authorized(:view, chained_inclusion_query).objects
        ).to include(paper)

        chained_exclusion_query = query.where(id: paper.id).where.not(name: paper.name)
        expect(
          user.filter_authorized(:view, chained_exclusion_query).objects
        ).to_not include(paper)
      end

      it 'does not include unauthorized models' do
        unauthorized_query = query.where(id: other_paper.id).where(name: other_paper.name)
        expect(
          user.filter_authorized(:view, unauthorized_query).objects
        ).to_not include(other_paper)
      end
    end

    context 'when given join-chained ActiveRecord::Relation(s)' do
      let(:query) {  Authorizations::FakePaper.all }

      it 'can filter authorized models given joined-chained ActiveRecord::Relation(s)' do
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

      it 'does not include unauthorized models' do
        unauthorized_query = query.joins(:fake_tasks).where(fake_tasks: { id: other_task.id })
        expect(
          user.filter_authorized(:view, unauthorized_query).objects
        ).to_not include(other_paper)
      end
    end
  end
end
