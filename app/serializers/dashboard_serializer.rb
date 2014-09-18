class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :total_paper_count, :total_page_count
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer

  def id
    1
  end

  def total_paper_count
    papers.total_count
  end

  def total_page_count
    papers.total_pages
  end

  def user
    @user ||= current_user
  end

  def papers
    user.assigned_papers.includes(:paper_roles).order("paper_roles.created_at DESC").page(1)
  end
end
