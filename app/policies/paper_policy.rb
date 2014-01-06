class PaperPolicy
  def initialize paper_id, user
    @paper_id = paper_id
    @user = user
  end

  def paper
    paper_for_author || submitted_paper_for_admin || submitted_paper_for_editor || submitted_paper_for_reviewer
  end

  private

  def paper_for_author
    @user.papers.where(id: @paper_id).first
  end

  def submitted_paper_for_admin
    Paper.submitted.where(id: @paper_id).first if @user.admin?
  end

  def submitted_paper_for_editor
    Paper.submitted.
      where(id: @paper_id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.editor = ?", @user.id, true).
      first
  end

  def submitted_paper_for_reviewer
    Paper.submitted.
      where(id: @paper_id).
      joins(:paper_roles).
      where("paper_roles.user_id = ? AND paper_roles.reviewer = ?", @user.id, true).
      first
  end
end
