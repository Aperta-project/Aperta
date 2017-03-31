class SupportingInformationFileSerializer < ActiveModel::Serializer
  root :supporting_information_file
  attributes :id,
             :filename,
             :alt,
             :src,
             :status,
             :label,
             :category,
             :title_html,
             :caption_html,
             :publishable,
             :created_at,
             :striking_image
  has_one :paper, embed: :id, include: false
end
