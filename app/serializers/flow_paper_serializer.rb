class FlowPaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :decision, :decision_letter, :authors
  has_many :phases, embed: :ids, include: true
  has_many :tasks, embed: :ids

  def authors
    object.authors
  end
end
