module PlosBioTechCheck
  class ChangesForAuthorTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    DEFAULT_TITLE = 'Changes For Author'
    DEFAULT_ROLE = 'author'
    SYSTEM_GENERATED = true

    def active_model_serializer
      TaskSerializer
    end

    def self.permitted_attributes
      super << :body
    end

    def letter_text
      body["initialTechCheckBody"]
    end

    def letter_text=(text)
      self.body ||= {}
      self.body = body.merge("initialTechCheckBody" => text)
    end

    def submit_tech_check!(submitted_by:)
      complete!
      if paper.submit_minor_check!(submitted_by)
        increment_initial_tech_check_round!
        notify_tech_fixed
        Activity.tech_check_fixed!(paper, user: submitted_by)
        true
      else
        false
      end
    end

    def notify_changes_for_author
      PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: self.id
      )
    end

    private

    def notify_tech_fixed
      paper.admins.each do |admin|
        PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_paper_tech_fixed(
          admin_id: admin.id,
          paper_id: paper.id
        )
      end
    end

    def initial_tech_check_tasks
      paper.tasks.of_type(InitialTechCheckTask)
    end

    def increment_initial_tech_check_round!
      initial_tech_check_tasks.map(&:increment_round!)
    end
  end
end
