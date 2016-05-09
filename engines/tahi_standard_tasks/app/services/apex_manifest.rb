# A class for creating a validated manifest file for for apex export
class ApexManifest
  class InvalidManifest < StandardError; end

  attr_writer :archive_filename, :metadata_filename

  def initialize(archive_filename: nil,
                 metadata_filename: nil,
                 apex_delivery_id: nil)
    @file_list = []
    @archive_filename = archive_filename
    @metadata_filename = metadata_filename
    @apex_delivery_id = apex_delivery_id
  end

  def add_file(filename)
    @file_list << filename
  end

  def as_json(_ = nil)
    manifest = {
      archive_filename: @archive_filename,
      metadata_filename: @metadata_filename,
      files: @file_list
    }
    if @apex_delivery_id.present?
      manifest[:apex_delivery_id] = @apex_delivery_id
    end
    manifest
  end

  def file
    fail_if_invalid
    Tempfile.new('manifest').tap do |f|
      f.write to_json
      f.rewind
    end
  end

  def fail_if_invalid
    fail InvalidManifest unless @archive_filename.present?
    fail InvalidManifest unless @metadata_filename.present?
  end
end
