class UserFlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :journal_name, :journal_logo
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  delegate :tasks, to: :query
  delegate :lite_papers, to: :query

  private

  def query
    @query ||= FlowQuery.new(scoped_user, flow)
  end

  def scoped_user
    scope.presence || options[:user]
  end

  def flow
    object.is_a?(Flow) ? object : object.flow
  end

  def journal
    flow.journal
  end

  def journal_name
    return unless journal
    journal.name
  end

  def journal_logo
    return unless journal
    journal.logo
  end
end
