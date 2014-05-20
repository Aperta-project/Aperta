class FigureSerializer < ActiveModel::Serializer
  attributes :id, :filename, :alt, :src, :title, :caption, :preview_src
  has_one :paper, embed: :ids
end
