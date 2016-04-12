module PlosBioTechCheck
  class ChangesForAuthorTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    DEFAULT_TITLE = 'Changes For Author'
    DEFAULT_ROLE = 'author'

    def active_model_serializer
      TaskSerializer
    end

    def self.permitted_attributes
      super << :body
    end

    def notify_changes_for_author
      PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_changes_for_author(
        author_id: paper.creator.id,
        task_id: self.id
      )
    end

    def notify_tech_fixed
      paper.admins.each do |admin|
        PlosBioTechCheck::ChangesForAuthorMailer.delay.notify_paper_tech_fixed(
          admin_id: admin.id,
          paper_id: paper.id
        )
      end
    end
  end
end
