class DashboardTaskSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :title, :type, :completed, :parent_type, :body, :paper_title, :isMessage
  has_one :phase
  has_one :paper
  has_one :assignee

  def parent_type
    'task'
  end

  def paper_title
    object.paper.display_title
  end

  def isMessage
    object.type == 'MessageTask'
  end

end
