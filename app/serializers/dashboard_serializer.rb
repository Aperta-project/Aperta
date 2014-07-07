class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :submissions, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
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

  def submissions
    # all the papers i have submitted
    @submissions ||= current_user.submitted_papers
  end
end
