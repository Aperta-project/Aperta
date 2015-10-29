class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :source_id, :source_type, :major_version, :minor_version, :contents, :created_at
end
