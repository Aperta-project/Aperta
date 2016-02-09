module PlosBioTechCheck
  class InitialTechCheckTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    DEFAULT_TITLE = 'Initial Tech Check'
    DEFAULT_ROLE = 'editor'

    before_create :initialize_round

    def active_model_serializer
      PlosBioTechCheck::InitialTechCheckTaskSerializer
    end

    def round
      body['round'] || 1
    end

    def increment_round!
      body['round'] = round.next
      save!
    end

    def notify_changes_for_author
      PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: self.changes_for_author_task.id
      )
    end

    def changes_for_author_task
      @_task ||= paper.tasks.detect { |task|
                task.type == "PlosBioTechCheck::ChangesForAuthorTask"
              }
      return @_task if @_task.present?

      @_task = PlosBioTechCheck::ChangesForAuthorTask.create!({
        body: {},
        title: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_TITLE,
        old_role: PlosBioTechCheck::ChangesForAuthorTask::DEFAULT_ROLE,
        paper: paper,
        phase: phase
      })
      @_task.add_participant(User.find(paper.creator.id))
      @_task.save!
      @_task
    end

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    private

    def initialize_round
      self.body = { round: 1 }
    end
  end
end
