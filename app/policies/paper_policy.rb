class PaperPolicy
  def initialize(paper_id, user)
    if paper_id.respond_to? :id
      @paper_id = paper_id.id
    else
      @paper_id = paper_id
    end
    @user = user
  end

  def paper
    paper_for_author || paper_for_admin || paper_for_editor || paper_for_reviewer
  end

  def tasks_for_paper(task_ids)
    paper ? paper.tasks.where(id: task_ids) : []
  end

  private
  def paper_for_author
    @user.submitted_papers.where(id: @paper_id).first
  end

  def paper_for_admin
    Paper.where(id: @paper_id).first if @user.admin?
  end

  def paper_for_editor
    Paper.
      where(id: @paper_id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.editor = ?", @user.id, true).
      first
  end

  def paper_for_reviewer
    Paper.
      where(id: @paper_id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.reviewer = ?", @user.id, true).
      first
  end
end
