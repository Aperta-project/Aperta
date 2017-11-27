class SnapshotSerializer < ActiveModel::Serializer
  attributes :id, :source_id, :source_type, :major_version, :minor_version, :contents, :created_at, :sanitized_contents

  def sanitized_contents
    # need to duplicate hash to prevent original contents object from being mutated
    require 'snapshot_sanitizer'
    SnapshotSanitizer.sanitize(object.contents.deep_dup)
  end
end
