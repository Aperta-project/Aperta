class FigureSerializer < ActiveModel::Serializer
  attributes :id, :filename, :alt, :src
  has_one :paper, embed: :ids
end
