class Snapshot::AttachmentSerializer < Snapshot::BaseSerializer
  def initialize(attachment)
    @attachment = attachment
  end

  def snapshot
    if @attachment.nil?
      return nil
    end
    properties = []

    properties << snapshot_property("file", "text", @attachment.model[:attachment])
    properties << snapshot_property("title", "text", @attachment.model[:title])
    properties << snapshot_property("caption", "text", @attachment.model[:caption])
    properties << snapshot_property("status", "text", @attachment.model[:status])

    properties
  end
end
