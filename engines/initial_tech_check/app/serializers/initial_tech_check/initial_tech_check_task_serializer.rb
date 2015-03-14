module InitialTechCheck
  class InitialTechCheckTaskSerializer < ::TaskSerializer
    has_one :changes_for_author_task, embed: :id

    def changes_for_author_task
      Task.find object.body["changesForAuthorTaskId"] if object.body.present?
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end
end
