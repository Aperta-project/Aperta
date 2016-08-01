# Serializes supporting information tasks and their accompanying
# files
class Snapshot::SupportingInformationTaskSerializer < Snapshot::BaseSerializer

  private

  def snapshot_properties
    model.supporting_information_files.order(:id).map do |file|
      Snapshot::AttachmentSerializer.new(file).as_json
    end
  end
end
