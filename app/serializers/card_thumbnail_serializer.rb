class CardThumbnailSerializer < ActiveModel::Serializer
  attributes :id, :task_type, :completed, :task, :title, :created_at
  has_one :lite_paper, embed: :id, include: true, serializer: LitePaperSerializer

  def task
    {id: object.id, type: type}
  end

  def task_type
    type
  end

  def type
    object.type.gsub(/.+::/,'')
  end

  def lite_paper
    object.paper
  end

end
