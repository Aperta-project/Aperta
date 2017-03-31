class FigureSerializer < ActiveModel::Serializer
  attributes :id,
             :filename,
             :alt,
             :src,
             :status,
             :title_html,
             :caption_html,
             :detail_src,
             :preview_src,
             :created_at,
             :striking_image,
             :rank

  has_one :paper, embed: :id
end
