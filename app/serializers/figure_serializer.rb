class FigureSerializer < ActiveModel::Serializer
  attributes :id,
             :filename,
             :alt,
             :src,
             :status,
             :title,
             :caption,
             :preview_src

  has_one :paper, embed: :id
end
