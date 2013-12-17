class PaperPolicy
  def initialize paper_id, user
    @paper_id = paper_id
    @user = user
  end

  def paper
    paper_for_author || submitted_paper_for_admin
  end

  private

  def paper_for_author
    @user.papers.where(id: @paper_id).first
  end

  def submitted_paper_for_admin
    Paper.where(id: @paper_id, submitted: true).first if @user.admin?
  end
end
