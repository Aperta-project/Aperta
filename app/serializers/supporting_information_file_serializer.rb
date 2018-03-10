class SupportingInformationFileSerializer < AuthzSerializer
  root :supporting_information_file
  attributes :id,
             :filename,
             :alt,
             :src,
             :status,
             :label,
             :category,
             :title,
             :caption,
             :publishable,
             :created_at
  has_one :paper, embed: :id, include: false

end
