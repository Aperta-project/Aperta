class FigureSerializer < ActiveModel::Serializer
  attributes :id, :filename, :alt, :src, :title, :caption
  has_one :paper, embed: :ids
end
