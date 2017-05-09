require 'rails_helper'

module PlosBioTechCheck
  describe NotifyAuthorOfChangesNeededService do
    subject(:service) do
      described_class.new(task, submitted_by: user)
    end

    let(:paper) do
      FactoryGirl.create(
        :paper,
        :submitted,
        :with_creator,
        journal: journal
      )
    end
    let(:journal) do
      FactoryGirl.create(
        :journal,
        :with_creator_role,
        :with_collaborator_role,
        :with_task_participant_role
      )
    end
    let(:user) { FactoryGirl.create(:user) }

    shared_examples_for 'a tech check task that notifies authors' do |task_factory:|
      let(:task) { FactoryGirl.create(task_factory, paper: paper) }

      context 'when the paper is not in a state of checking' do
        before { expect(paper.checking?).to be false }

        it 'puts the paper to in a state of checking' do
          service.notify!
          expect(task.paper.checking?).to be true
        end
      end

      it 'queues up emails to notify the author of changes' do
        service.notify!

        changes_for_author_task = task.paper.tasks.of_type(
          ChangesForAuthorTask
        ).first!

        expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
          ChangesForAuthorMailer,
          :notify_changes_for_author,
          [{ author_id: paper.creator.id, task_id: changes_for_author_task.id }]
        )
      end

      it 'creates an Activity feed item' do
        expect do
          service.notify!
        end.to change { Activity.count }
        expect(Activity.find_by(
                 feed_name: 'workflow',
                 activity_key: 'task.sent_to_author',
                 subject: task.paper,
                 user: user,
                 message: "#{task.title} sent to author"
        )).to be
      end

      describe 'updates to the corresponding ChangesForAuthorTask' do
        let(:author) { FactoryGirl.create(:user, first_name: 'Author') }
        let!(:changes_task) do
          FactoryGirl.create(:changes_for_author_task, paper: paper)
        end

        before do
          task.letter_text = 'Hello world!'
          paper.creator = author
        end

        it 'updates its letter text' do
          expect do
            service.notify!
          end.to change { changes_task.reload.body['initialTechCheckBody'] }.to 'Hello world!'
        end

        it 'marks it as incomplete' do
          changes_task.update_column(:completed, true)
          expect do
            service.notify!
          end.to change { changes_task.reload.completed? }.to be false
        end

        it <<-DESC.strip_heredoc do
          adds the paper creator, collaborators, and the submitting user as
          its task participants
        DESC
          joe = FactoryGirl.create(:user)
          sam = FactoryGirl.create(:user)
          steve = FactoryGirl.create(:user)

          paper.add_collaboration(joe)
          paper.add_collaboration(steve)

          service.notify!

          expect(changes_task.participants).to contain_exactly(
            paper.creator, user, joe, steve
          )
          expect(changes_task.participants).to_not include(sam)
        end

        it 'creates a ChangesForAuthorTask when one does not exist' do
          changes_task.destroy
          expect do
            service.notify!
          end.to change { ChangesForAuthorTask.count }.by(1)
          new_task = ChangesForAuthorTask.last
          expect(new_task.body).to eq('initialTechCheckBody' => 'Hello world!')
          expect(new_task.title).to eq ChangesForAuthorTask::DEFAULT_TITLE
          expect(new_task.paper).to eq task.paper
          expect(new_task.phase).to eq task.phase
        end
      end
    end

    describe '#notify!' do
      it_behaves_like 'a tech check task that notifies authors',
        task_factory: :initial_tech_check_task
      it_behaves_like 'a tech check task that notifies authors',
        task_factory: :revision_tech_check_task
      it_behaves_like 'a tech check task that notifies authors',
        task_factory: :final_tech_check_task
    end
  end
end
