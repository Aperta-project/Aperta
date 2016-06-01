class DecisionSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :verdict,
             :revision_number,
             :letter,
             :is_latest,
             :is_latest_registered,
             :author_response,
             :registered,
             :initial,
  has_many :invitations, embed: :ids, include: true
  has_one :paper, embed: :id

  # rubocop:disable Style/PredicateName
  # the question marks won't play well with serialization
  def is_latest
    object.latest?
  end

  def is_latest_registered
    object.latest_registered?
  end

  # rubocop:enable Style/PredicateName
end
