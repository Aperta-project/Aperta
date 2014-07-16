class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :papers, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :administered_journals

  def id
    1
  end

  def user
    @user ||= current_user
  end

  def administered_journals
    user.administered_journals
  end

  def papers
    # all the papers i have submitted
    ids = current_user.submitted_papers.pluck(:id) | current_user.assigned_papers.pluck(:id)
    roles = PaperRole.where(paper_id: ids, user_id: current_user.id)
    Paper.find(ids).includes(:paper_roles)
  end
end
