class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :source_id, :source_type, :major_version, :minor_version, :contents, :created_at, :sanitized_contents

  def sanitized_contents
    SnapshotSanitizer.sanitize(object.contents)
  end
end
