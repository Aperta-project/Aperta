class TokenCoauthorSerializer < ActiveModel::Serializer
  attributes :id, :token

  has_one :paper, embed: :id, include: true
end
