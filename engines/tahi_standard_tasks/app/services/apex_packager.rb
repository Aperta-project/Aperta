# This class creates a temporary ZIP file for FTP to Apex
class ApexPackager
  attr_reader :zip_file

  class ApexPackagerError < StandardError
  end

  def self.create(paper)
    packager = new(paper)
    packager.zip
    packager
  end

  def initialize(paper, archive_filename: nil)
    @paper = paper
    @zip_file = Tempfile.new('zip')
    @archive_filename = archive_filename
  end

  def zip
    Zip::OutputStream.open(@zip_file) do |package|
      add_figures(package)
      add_striking_image(package)
      add_supporting_information(package)
      add_metadata(package)
      add_manuscript(package)
    end
  end

  def manifest
    @manifest ||= ApexManifest.new(archive_filename: @archive_filename)
  end

  private

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
                        @paper.striking_image.attachment.read
  end

  def add_figures(package)
    @paper.figures.each do |figure|
      next if @paper.striking_image == figure
      add_file_to_package package,
                          attachment_apex_filename(figure),
                          figure.attachment.read
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
                          file.attachment.read
    end
  end

  def add_metadata(package)
    filename = 'metadata.json'
    metadata = Typesetter::MetadataSerializer.new(@paper).to_json
    temp_file = Tempfile.new('metadata')
    temp_file.write(metadata)
    temp_file.rewind
    add_file_to_package package,
                        filename,
                        temp_file.read
    temp_file.close
    manifest.metadata_filename = filename
  end

  def add_file_to_package(package, filename, file_contents)
    package.put_next_entry(filename)
    package.write(file_contents)
    manifest.add_file(filename)
  end
end
