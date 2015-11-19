class VersionedTextSerializer < ActiveModel::Serializer
  attributes :id, :text, :updated_at, :version_string, :paper_id,
             :major_version, :minor_version
end
