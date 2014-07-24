class PaperEditorTask < Task
  def permitted_attributes
    super + [:editor_id, { paper_role_attributes: [:user_id, :editor_id] }]
  end

  title 'Assign Editor'
  role 'admin'

  has_many :paper_roles, through: :paper

  def paper_role
    @paper_role ||= paper_roles.editors.first_or_initialize(paper_id: paper.id)
  end

  def paper_role_attributes=(attributes)
    paper_role.update attributes
  end

  def editor_id=(user_id)
    return unless editor_id != user_id
    current_paper_role = paper_role
    paper_role.user_id = user_id
    paper_role.save!
  end

  def editor_id
    paper_role.user_id
  end

  def editor
    paper_role.user
  end

  def editors
    journal.editors
  end
end
