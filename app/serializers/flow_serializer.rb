class FlowSerializer < ActiveModel::Serializer
  attributes :id, :old_role_id, :journal_logo, :journal_name, :position, :query, :task_roles, :title

  has_many :papers, embed: :ids, include: true, serializer: LitePaperSerializer
  has_many :tasks, embed: :ids, include: true, root: :card_thumbnails, serializer: CardThumbnailSerializer
  has_many :journal_task_types, embed: :ids, include: true

  delegate :tasks, to: :flow_query
  delegate :papers, to: :flow_query
  delegate :journal_task_types, to: :journal

  private

  def task_roles
    Task.unscoped.select(:old_role).distinct.pluck(:old_role)
  end

  def journal
    object.journal
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

  def journal_name
    flow.journal.try(:name)
  end

  def journal_logo
    flow.journal.try(:logo_url)
  end
end
