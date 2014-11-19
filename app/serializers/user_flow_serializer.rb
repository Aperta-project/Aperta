class UserFlowSerializer < ActiveModel::Serializer
  attributes :id, :title
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  delegate :tasks, to: :query
  delegate :lite_papers, to: :query

  private

  def query
    @query ||= FlowQuery.new(scoped_user, object.title)
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
