class PaperQuery
  def initialize(paper_id, user)
    if paper_id.respond_to? :id
      @paper_id = paper_id.id
    else
      @paper_id = paper_id
    end
    @user = user
  end

  def paper
    paper_for_author || paper_for_site_admin || paper_for_paper_admin || paper_for_editor || paper_for_reviewer || paper_for_sufficient_role
  end

  def tasks_for_paper(task_ids)
    paper ? paper.tasks.where(id: task_ids) : []
  end

  private
  def paper_for_author
    @user.submitted_papers.where(id: @paper_id).first
  end

  def paper_for_site_admin
    Paper.where(id: @paper_id).first if @user.admin?
  end

  def paper_for_paper_admin
    Paper.
      where(id: @paper_id).
      joins(:paper_roles).
      merge(PaperRole.admins.for_user(@user)).
      first
  end

  def paper_for_editor
    Paper.
      where(id: @paper_id).
      joins(:paper_roles).
      merge(PaperRole.editors.for_user(@user)).
      first
  end

  def paper_for_reviewer
    Paper.
      where(id: @paper_id).
      joins(:paper_roles).
      merge(PaperRole.reviewers.for_user(@user)).
      first
  end

  def paper_for_sufficient_role
    paper = Paper.where(id: @paper_id).first
    if @user.roles.where(journal_id: paper.journal.id).where(can_view_all_manuscript_managers: true).present?
      paper
    end
  end
end
