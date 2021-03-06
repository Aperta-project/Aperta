# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# This class creates a temporary ZIP file for FTP to Apex
class ExportPackager
  class ExportPackagerError < StandardError
  end

  METADATA_FILENAME = 'metadata.json'.freeze

  def self.create_zip(paper, destination:)
    packager = new(paper, destination: destination)
    packager.zip_file
  end

  def initialize(paper, archive_filename: nil, delivery_id: nil, destination:)
    @paper = paper
    @archive_filename = archive_filename
    @delivery_id = delivery_id
    @destination = destination
  end

  def zip_file
    @zip_file ||= Tempfile.new('zip').tap do |f|
      Zip::OutputStream.open(f) do |package|
        add_figures(package)
        add_cover_letter(package) if article_router_package?
        add_supporting_information(package)
        add_metadata(package)
        add_manuscript(package)
        add_sourcefile_if_needed(package)
        add_generated_pdf(package) if include_pdf?
      end
    end
  end

  def manifest_file
    zip_file
    manifest.file
  end

  def manifest
    @manifest ||= ExportManifest.new archive_filename: @archive_filename,
                                     metadata_filename: METADATA_FILENAME,
                                     delivery_id: @delivery_id,
                                     destination: @destination
  end

  private

  def include_pdf?
    article_router_package?
  end

  def article_router_package?
    @destination != 'apex'
  end

  def add_generated_pdf(package)
    package.put_next_entry(converter.output_filename)
    package.write(converter.output_data)
    manifest.add_file(converter.output_filename)
  end

  def converter
    @converter ||= PaperConverters::PaperConverter.make(@paper.latest_version, 'pdf_for_router', nil)
  end

  def add_sourcefile_if_needed(package)
    return unless @paper.file_type == 'pdf' && @paper.sourcefile
    url = @paper.sourcefile.url
    add_file_to_package package,
      source_filename,
      open(url, &:read)
  end

  def add_manuscript(package)
    url = @paper.file.url
    add_file_to_package package,
      manuscript_filename,
      open(url, &:read)
  end

  def source_filename
    extension = @paper.sourcefile.filename.split('.').last
    "#{@paper.manuscript_id}.#{extension}"
  end

  def manuscript_filename
    extension = @paper.file.filename.split('.').last
    "#{@paper.manuscript_id}.#{extension}"
  end

  def cover_letter_filename
    extension = @paper.file.filename.split('.').last
    "aperta-cover-letter-#{@paper.short_doi}.#{extension}"
  end

  def add_figures(package)
    @paper.figures.each do |figure|
      add_file_to_package package,
                          figure.filename,
                          figure.file.read
    end
  end

  def add_cover_letter(package)
    letter = @paper.question_attachments.cover_letter.first
    add_file_to_package(package, cover_letter_filename, letter.file.read) if letter
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
    metadata = Typesetter::MetadataSerializer.new(@paper, destination: @destination).to_json
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
