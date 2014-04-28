class CardThumbnailSerializer < ActiveModel::Serializer
  attributes :id, :task_type, :completed, :task, :title
  has_one :paper, embed: :id
  has_one :assignee, embed: :id

  def task
    {id: object.id, type: type}
  end

  def task_type
    type
  end

  def type
    object.type.gsub(/.+::/,'')
  end

end
