# This class creates a temporary ZIP file for FTP to Apex
class ApexPackager
  class ApexPackagerError < StandardError
  end

  METADATA_FILENAME = 'metadata.json'

  def self.create_zip(paper)
    packager = new(paper)
    packager.zip_file
  end

  def initialize(paper, archive_filename: nil, apex_delivery_id: nil)
    @paper = paper
    @archive_filename = archive_filename
    @apex_delivery_id = apex_delivery_id
  end

  def zip_file
    @zip_file ||= Tempfile.new('zip').tap do |f|
      Zip::OutputStream.open(f) do |package|
        add_figures(package)
        add_striking_image(package)
        add_supporting_information(package)
        add_metadata(package)
        add_manuscript(package)
      end
    end
  end

  def manifest_file
    zip_file
    manifest.file
  end

  private

  def manifest
    @manifest ||= ApexManifest.new archive_filename: @archive_filename,
                                   metadata_filename: METADATA_FILENAME,
                                   apex_delivery_id: @apex_delivery_id
  end

  def add_manuscript(package)
    add_file_to_package package,
                        manuscript_filename,
                        open(@paper.latest_version.source_url, &:read)
  end

  def manuscript_filename
    extension = @paper.latest_version.source.path.split('.').last
    "#{@paper.manuscript_id}.#{extension}"
  end

  def add_striking_image(package)
    return unless @paper.striking_image
    add_file_to_package package,
                        attachment_apex_filename(@paper.striking_image),
                        @paper.striking_image.file.read
  end

  def add_figures(package)
    @paper.figures.each do |figure|
      next if @paper.striking_image == figure
      add_file_to_package package,
                          attachment_apex_filename(figure),
                          figure.file.read
    end
  end

  def attachment_apex_filename(attachment)
    return attachment.filename unless attachment == @paper.striking_image

    extension = attachment.filename.split('.').last
    "Strikingimage.#{extension}"
  end

  def add_supporting_information(package)
    @paper.supporting_information_files.each do |file|
      next unless file.publishable?
      add_file_to_package package,
                          file.filename,
                          file.file.read
    end
  end

  def add_metadata(package)
    metadata = Typesetter::MetadataSerializer.new(@paper).to_json
    temp_file = Tempfile.new('metadata')
    temp_file.write(metadata)
    temp_file.rewind
    add_file_to_package package,
                        METADATA_FILENAME,
                        temp_file.read
    temp_file.close
  end

  def add_file_to_package(package, filename, file_contents)
    package.put_next_entry(filename)
    package.write(file_contents)
    manifest.add_file(filename)
  end
end
