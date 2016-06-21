class DecisionSerializer < ActiveModel::Serializer
  attributes :author_response,
             :created_at,
             :id,
             :is_latest,
             :letter,
             :verdict,
             :revision_number

  has_many :invitations, embed: :ids, include: true
  has_one :paper, embed: :id, include: true

  def is_latest
    object.latest?
  end
end
