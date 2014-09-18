class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :total_paper_count, :total_page_count
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer

  def id
    1
  end

  def total_paper_count
    most_recent_paper_roles.total_count
  end

  def total_page_count
    most_recent_paper_roles.total_pages
  end

  def user
    @user ||= current_user
  end

  def papers
    most_recent_paper_roles.map(&:paper)
  end

  def most_recent_paper_roles
    PaperRole.select("paper_id, max(created_at) as max_created").group(:paper_id).for_user(user).order("max_created DESC").page(1)
  end
end
