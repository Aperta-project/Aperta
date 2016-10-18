shared_examples 'a PlosBioTechCheck that notifies the author of changes' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  subject!(:task) do
    FactoryGirl.create(task_class, paper: paper)
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

  describe '#notify_author_of_changes!' do
    context 'when the paper is not in a state of checking' do
      before { expect(paper.checking?).to be false }

      it 'puts the paper to in a state of checking' do
        task.notify_author_of_changes!(submitted_by: user)
        expect(task.paper.checking?).to be true
      end
    end

    it 'queues up emails to notify the author of changes' do
      task.notify_author_of_changes!(submitted_by: user)

      changes_for_author_task = task.paper.tasks.of_type(
        PlosBioTechCheck::ChangesForAuthorTask
      ).first!

      expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
        PlosBioTechCheck::ChangesForAuthorMailer,
        :notify_changes_for_author,
        [{author_id: paper.creator.id, task_id: changes_for_author_task.id}]
      )
    end

    it 'creates an Activity feed item' do
      expect do
        task.notify_author_of_changes!(submitted_by: user)
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
          task.notify_author_of_changes!(submitted_by: user)
        end.to change { changes_task.reload.body['initialTechCheckBody'] }.to 'Hello world!'
      end

      it 'marks it as incomplete' do
        changes_task.update_column(:completed, true)
        expect do
          task.notify_author_of_changes!(submitted_by: user)
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

        task.notify_author_of_changes!(submitted_by: user)

        expect(changes_task.participants).to contain_exactly(
          paper.creator, user, joe, steve
        )
        expect(changes_task.participants).to_not include(sam)
      end

      it 'creates a ChangesForAuthorTask when one does not exist' do
        changes_task.destroy
        expect do
          task.notify_author_of_changes!(submitted_by: user)
        end.to change { PlosBioTechCheck::ChangesForAuthorTask.count }.by(1)
        new_task = PlosBioTechCheck::ChangesForAuthorTask.last
        expect(new_task.body).to eq('initialTechCheckBody' => 'Hello world!')
        expect(new_task.title).to eq PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_TITLE
        expect(new_task.old_role).to eq PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_ROLE
        expect(new_task.paper).to eq task.paper
        expect(new_task.phase).to eq task.phase
      end
    end

  end

end
