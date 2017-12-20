class TokenCoauthorSerializer < ActiveModel::Serializer
  attributes :id, :token

  # has_one :paper
end
