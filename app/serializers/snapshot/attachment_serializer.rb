class Snapshot::AttachmentSerializer < Snapshot::BaseSerializer
  def initialize(attachment)
    @attachment = attachment
  end

  def snapshot
    if @attachment.nil?
      return nil
    end

    {
      file: @attachment.model[:attachment],
      title: @attachment.model[:title],
      caption: @attachment.model[:caption],
      status: @attachment.model[:status]
    }
  end
end
