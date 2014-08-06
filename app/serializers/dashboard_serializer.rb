class DashboardSerializer < ActiveModel::Serializer
  attributes :id, :total_paper_count, :total_page_count
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :administered_journals

  def id
    1
  end

  def total_paper_count
    total_paper_ids.length
  end

  def total_page_count
    (total_paper_count / Paper::PAGE_SIZE.to_f).ceil
  end

  def user
    @user ||= current_user
  end

  def administered_journals
    user.administered_journals
  end

  def papers
    Paper.where(id: total_paper_ids).includes(:paper_roles).paginate(1).all
  end

  private

  def total_paper_ids
    @ids ||= user.assigned_papers.pluck :id
  end
end
