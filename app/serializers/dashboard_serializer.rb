class DashboardSerializer < ActiveModel::Serializer
  attribute :id
  has_one :user, embed: :id, include: true
  has_many :submissions, embed: :ids, include: true, root: :lite_papers, serializer: LitePaperSerializer
  has_many :assigned_tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  def id
    1
  end

  def user
    current_user
  end

  def submissions
    # all the papers i have submitted
    current_user.papers
  end

  def assigned_tasks
    # all the tasks I have been associated with
    (current_user.tasks + current_user.papers.flat_map(&:message_tasks)).uniq
  end
end
