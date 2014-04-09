class DeclarationSerializer < ActiveModel::Serializer
  attributes :id, :question, :answer
  has_one :paper, embed: :ids
end
