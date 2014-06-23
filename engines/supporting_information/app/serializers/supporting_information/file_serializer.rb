module SupportingInformation
  class FileSerializer < ActiveModel::Serializer
    root :supporting_information_file
    attributes :id, :filename, :alt, :src, :status, :title, :caption
    has_one :paper, embed: :id, include: false
  end
end
