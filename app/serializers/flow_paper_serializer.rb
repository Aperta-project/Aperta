class FlowPaperSerializer < ActiveModel::Serializer
  attributes :id, :short_title, :title, :decision, :decision_letter, :authors
  has_many :phases, embed: :ids, include: true
  has_many :tasks, embed: :ids
  # Flow manager page makes a request for the journal when updating the paper,
  # but we just need the id..? Would prefer to not have to include journal to
  # avoid this error.
  has_one :journal, embed: :id, include: true

  def authors
    object.authors
  end
end
