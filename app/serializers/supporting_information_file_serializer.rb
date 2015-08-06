class SupportingInformationFileSerializer < ActiveModel::Serializer
  root :supporting_information_file
  attributes :id,
             :filename,
             :alt,
             :src,
             :status,
             :title,
             :caption,
             :detail_src,
             :publishable,
             :preview_src,
             :created_at
  has_one :paper, embed: :id, include: false
end
