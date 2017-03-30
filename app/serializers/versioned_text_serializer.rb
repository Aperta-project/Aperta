class VersionedTextSerializer < ActiveModel::Serializer
  attributes :id, :text, :updated_at, :paper_id,
    :major_version, :minor_version, :version_string, :file_type,
    :source_type

  def source_type
    object.sourcefile_filename.split('.')[-1] if object.sourcefile_filename
  end
end
