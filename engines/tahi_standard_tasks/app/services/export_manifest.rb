# A class for creating a validated manifest file for apex/router export
class ExportManifest
  class InvalidManifest < StandardError; end

  attr_accessor :archive_filename, :metadata_filename, :delivery_id
  attr_reader :file_list

  def initialize(archive_filename:,
                 metadata_filename:,
                 destination:,
                 delivery_id: nil)
    @file_list = []
    @archive_filename = archive_filename
    @metadata_filename = metadata_filename
    @delivery_id = delivery_id
    @destination = destination
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
      m[delivery_id_key] = delivery_id if delivery_id.present?
    end
  end

  def file
    Tempfile.new('manifest').tap do |f|
      f.write to_json
      f.rewind
    end
  end

  private

  def delivery_id_key
    @destination == 'apex' ? :delivery_id : :export_delivery_id
  end
end
