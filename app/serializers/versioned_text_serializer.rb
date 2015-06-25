class VersionedTextSerializer < ActiveModel::Serializer
  attributes :id, :text, :created_at, :version_string, :paper_id
end
