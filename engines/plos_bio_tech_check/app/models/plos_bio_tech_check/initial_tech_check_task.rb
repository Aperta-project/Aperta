module PlosBioTechCheck
  class InitialTechCheckTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    register_task default_title: 'Initial Tech Check', default_role: 'editor'
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

      task_properties = TaskType.types["PlosBioTechCheck::ChangesForAuthorTask"]
      @_task = PlosBioTechCheck::ChangesForAuthorTask.create!({
        body: {},
        title: task_properties[:default_title],
        old_role: task_properties[:default_role],
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
