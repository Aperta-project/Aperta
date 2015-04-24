class CardThumbnailSerializer < ActiveModel::Serializer
  attributes :id, :task_type, :completed, :task, :title, :created_at
  has_one :paper, embed: :id, include: true, serializer: LitePaperSerializer

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
