module PlosBioTechCheck
  class ChangesForAuthorTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    after_save :ensure_paper_editable!

    after_update :uncomplete_task, if: :body_changed?

    register_task default_title: "Changes For Author", default_role: "author"

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

    private

    def ensure_paper_editable!
      if not completed and not paper.checking?
        paper.minor_check!
      end
    end

    def uncomplete_task
      update_column :completed, false
    end
  end
end
