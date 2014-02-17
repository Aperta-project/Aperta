class PaperEditorTask < Task
  PERMITTED_ATTRIBUTES = [{ paper_role_attributes: [:user_id] }]

  title 'Assign Editor'
  role 'admin'

  def paper_role
    PaperRole.where(paper: paper, editor: true).first_or_initialize
  end

  def paper_role_attributes=(attributes)
    paper_role.update attributes
  end

  def editor_id
    paper_role.user_id
  end

  def editors
    User.editors_for(paper.journal)
  end
end
