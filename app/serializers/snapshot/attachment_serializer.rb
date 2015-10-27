class Snapshot::AttachmentSerializer < Snapshot::BaseSerializer
  def initialize(attachment)
    @attachment = attachment
  end

  def as_json
    return unless @attachment
    [
      snapshot_property("file", "text", @attachment[:file]),
      snapshot_property("title", "text", @attachment[:title]),
      snapshot_property("caption", "text", @attachment[:caption]),
      snapshot_property("status", "text", @attachment[:status])
    ]
  end
end
