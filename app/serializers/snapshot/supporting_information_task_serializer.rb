class Snapshot::SupportingInformationTaskSerializer < Snapshot::BaseTaskSerializer
  def snapshot_properties
    paper = Paper.find(@task.paper)
    properties = []
    paper.supporting_information_files.order(:id).each do |file|
      properties << { file: snapshot_file(file)}
    end
    properties
  end

  def snapshot_file file
    properties = []
    attachment_serializer = Snapshot::AttachmentSerializer.new file.attachment
    properties << ["attachment", attachment_serializer.snapshot]
    properties << snapshot_property("title", "text", file.title)
    properties << snapshot_property("caption", "text", file.caption)
    properties << snapshot_property("publishable", "boolean", file.publishable)
    properties << snapshot_property("status", "text", file.status)
  end
end
