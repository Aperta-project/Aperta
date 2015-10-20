class Snapshot::SupportingInformationTaskSerializer < Snapshot::BaseTaskSerializer
  def snapshot_properties
    paper = Paper.find(@task.paper.id)
    properties = []
    paper.supporting_information_files.order(:id).each do |file|
      properties << { name: "file", type: "properties", children: snapshot_file(file)}
    end
    properties
  end

  def snapshot_file file
    properties = []
    attachment_serializer = Snapshot::AttachmentSerializer.new file.attachment
    properties << {name: "attachment", type: "properties", children: attachment_serializer.snapshot}
    properties << snapshot_property("publishable", "boolean", file.publishable)
    properties << snapshot_property("status", "text", file.status)
  end
end
