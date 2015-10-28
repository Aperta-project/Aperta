class Snapshot::SupportingInformationTaskSerializer < Snapshot::TaskSerializer

  private

  def snapshot_properties
    @task.paper.supporting_information_files.order(:id).map do |file|
      {
        name: "supporting-information-file",
        type: "properties",
        children: snapshot_file_properties(file)
      }
    end
  end

  def snapshot_file_properties(file)
    [
      snapshot_property("file", "text", file[:attachment]),
      snapshot_property("title", "text", file.title),
      snapshot_property("caption", "text", file.caption),
      snapshot_property("publishable", "boolean", file.publishable),
      snapshot_property("status", "text", file.status)
    ]
  end
end
