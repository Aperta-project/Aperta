# A class for creating a validated manifest file for for apex export
class ApexManifest
  class InvalidManifest < StandardError; end

  attr_accessor :archive_filename, :metadata_filename, :apex_delivery_id
  attr_reader :file_list

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
    {
      archive_filename: archive_filename,
      metadata_filename: metadata_filename,
      files: file_list
    }.tap do |m|
      m[:apex_delivery_id] = apex_delivery_id if apex_delivery_id.present?
    end
  end

  def file
    fail_if_invalid
    Tempfile.new('manifest').tap do |f|
      f.write to_json
      f.rewind
    end
  end

  def fail_if_invalid
    [:archive_filename, :metadata_filename].each do |attr|
      fail InvalidManifest, "Missing #{attr}" unless send(attr).present?
    end
  end
end
