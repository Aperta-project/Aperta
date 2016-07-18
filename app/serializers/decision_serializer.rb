class DecisionSerializer < ActiveModel::Serializer
  attributes :author_response,
             :created_at,
             :id,
             :initial,
             :latest?,
             :latest_registered?,
             :letter,
             :major_version,
             :minor_version,
             :registered_at,
             :rescindable?,
             :rescinded,
             :verdict

  has_many :invitations, embed: :ids, include: true
  has_one :paper, embed: :id, include: true
end
