# A class for creating a validated manifest file for for apex export
class ApexManifest
  class InvalidManifest < StandardError; end

  attr_writer :archive_filename, :metadata_filename

  def initialize(archive_filename: nil, metadata_filename: nil)
    @file_list = []
    @archive_filename = archive_filename
    @metadata_filename = metadata_filename
  end

  def add_file(filename)
    @file_list << filename
  end

  def to_json
    {
      archive_filename: @archive_filename,
      metadata_filename: @metadata_filename,
      files: @file_list
    }.to_json
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
