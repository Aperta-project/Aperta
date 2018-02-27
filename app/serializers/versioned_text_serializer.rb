class VersionedTextSerializer < AuthzSerializer
  attributes :id, :text, :updated_at, :paper_id,
    :major_version, :minor_version, :file_type,
    :source_type

  def source_type
    object.sourcefile_filename.split('.')[-1] if object.sourcefile_filename
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
