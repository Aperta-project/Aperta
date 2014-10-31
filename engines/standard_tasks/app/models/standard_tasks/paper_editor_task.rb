module StandardTasks
  class PaperEditorTask < Task
    def permitted_attributes
      super + [:editor_id, { paper_role_attributes: [:user_id, :editor_id] }]
    end

    register_task default_title: "Assign Editor", default_role: "admin"

    has_many :paper_roles, through: :paper

    def paper_role
      paper_roles.editors.first_or_initialize(paper_id: paper.id)
    end

    def paper_role_attributes=(attributes)
      paper_role.update attributes
    end

    def editor_id=(user_id)
      return unless editor_id != user_id
      TaskRoleUpdater.new(self, user_id, PaperRole::EDITOR).update
    end

    def editor_id
      paper_role.user_id
    end
  end
end
