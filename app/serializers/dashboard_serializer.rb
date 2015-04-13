class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :total_paper_count, :total_page_count
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :invitations, embed: :ids, include: true

  def id
    1
  end

  def total_paper_count
    most_recent_paper_roles.total_count
  end

  def total_page_count
    most_recent_paper_roles.total_pages
  end

  def papers
    most_recent_paper_roles.map(&:paper)
  end

  def most_recent_paper_roles
    PaperRole.most_recent_for(user).page(1)
  end

  def user
    scoped_user
  end

  def invitations
    scoped_user.invitations_from_latest_revision
  end

  private

  def scoped_user
    scope.presence || options[:user]
  end
end
