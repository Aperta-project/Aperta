class UserFlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :journal_name, :journal_logo
  has_many :lite_papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer

  delegate :tasks, to: :flow_query
  delegate :lite_papers, to: :flow_query

  private

  def journal_name
    flow.journal.name if flow.journal
  end

  def journal_logo
    flow.journal.logo if flow.journal
  end

  def flow_query
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
    journal.logo_url
  end
end
