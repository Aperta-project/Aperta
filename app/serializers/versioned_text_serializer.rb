class VersionedTextSerializer < ActiveModel::Serializer
  attributes :id, :text, :updated_at, :paper_id,
             :major_version, :minor_version
end
