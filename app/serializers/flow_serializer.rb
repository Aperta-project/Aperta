class FlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :empty_text
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  def tasks
    query.tasks
  end

  def lite_papers
    query.lite_papers
  end

  private

  def query
    @query ||= FlowQuery.new(scoped_user, object.title)
  end

  def scoped_user
    scope.presence || options[:user]
  end
end
