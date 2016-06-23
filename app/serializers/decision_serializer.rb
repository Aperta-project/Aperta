class DecisionSerializer < ActiveModel::Serializer
  attributes :id,
             :author_response,
             :created_at,
             :verdict,
             :letter,
             :is_latest,
             :is_latest_registered,
             :author_response,
             :registered_at,
             :initial,
             :rescinded,
             :rescindable,
             :major_version,
             :minor_version

  has_many :invitations, embed: :ids, include: true
  has_one :paper, embed: :id, include: true

  # rubocop:disable Style/PredicateName
  # the question marks won't play well with serialization
  def is_latest
    object.latest?
  end

  def is_latest_registered
    object.latest_registered?
  end

  def rescindable
    object.rescindable?
  end
  # rubocop:enable Style/PredicateName
end
