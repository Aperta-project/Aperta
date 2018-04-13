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

require 'rails_helper'

describe ExportPackager do
  let(:paper) { FactoryGirl.create(:paper, :with_phases) }
  let!(:figures_task) { FactoryGirl.create(:figure_task, :with_loaded_card, paper: paper) }
  let!(:manuscript_file) do
    instance_double(ManuscriptAttachment, filename: 'manuscript_file.docx')
  end
  let(:zip_file) { Tempfile.new('zip') }
  let(:archive_filename) { 'test.0001.zip' }

  def zip_filenames(package)
    filenames = []
    Zip::InputStream.open(package) do |io|
      while (entry = io.get_next_entry)
        filenames << entry.name
      end
    end
    filenames
  end

  def read_zip_entry(zip_io, file_name)
    Zip::InputStream.open(zip_io) do |io|
      while (entry = io.get_next_entry)
        return io.read if entry.name == file_name
      end
    end
    nil
  end

  def zip_contains(zip_io, file_in_zip, expected_path)
    expected_contents = File.open(expected_path, 'rb', &:read)
    expected_contents == read_zip_entry(zip_io, file_in_zip)
  end

  let(:metadata_serializer) { instance_double('Typesetter::MetadataSerializer') }

  before do
    # create a version (last_version.file_type value used by dynamic paper converter)
    paper.versioned_texts = []
    paper.save!
    FactoryGirl.create(:versioned_text, paper: paper, major_version: 0, minor_version: 1)

    allow(paper).to receive(:file).and_return(manuscript_file)
    allow(paper).to receive(:manuscript_id).and_return('test.0001')
    allow(manuscript_file).to receive(:url).and_return(
      Rails.root.join('spec/fixtures/about_turtles.docx')
    )

    allow(metadata_serializer).to receive(:to_json).and_return('json')
    allow(Typesetter::MetadataSerializer).to \
      receive(:new).and_return(metadata_serializer)
  end

  context 'a well formed paper' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.card.content_for_version(:latest).find_by(ident: 'figures--complies') }
    let!(:answer) do
      FactoryGirl.create(:answer,
                         card_content: figure_question,
                         value: 'true',
                         owner: task,
                         owner_type: 'Task')
    end

    it 'creates a zip package for a paper' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(zip_filenames(zip_io)).to include(
        'test.0001.docx'
      )
    end

    it 'creates a zip package for a paper2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(zip_contains(zip_io,
                          'test.0001.docx',
                          Rails.root.join(
                            'spec/fixtures/about_turtles.docx'
                          ))).to be(true)
    end

    it 'contains the correct metadata' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      contents = read_zip_entry(zip_io, 'metadata.json')
      expect(contents).to eq('json')
    end

    it 'creates a valid manifest without a pdf when exporting to apex' do
      packager = ExportPackager.new(paper, archive_filename: archive_filename, destination: 'apex')
      packager.zip_file
      manifest = JSON.parse(packager.send(:manifest).to_json)
      expected_manifest = {
        "archive_filename" => archive_filename,
        "metadata_filename" => "metadata.json",
        "files" => ["metadata.json", "test.0001.docx"]
      }
      expect(manifest).to eq expected_manifest
    end

    it 'creates a valid manifest with a pdf when exporting to the preprint server' do
      packager = ExportPackager.new(paper, destination: 'preprint', archive_filename: archive_filename)
      packager.zip_file
      manifest = JSON.parse(packager.send(:manifest).to_json)
      expected_manifest = {
        "archive_filename" => archive_filename,
        "metadata_filename" => "metadata.json",
        "files" => ["metadata.json", "test.0001.docx", "aperta-generated-PDF.pdf"]
      }
      expect(manifest).to eq expected_manifest
    end

    it 'creates a valid manifest with a pdf when exporting to the EM server' do
      packager = ExportPackager.new(paper, destination: 'em', archive_filename: archive_filename)
      packager.zip_file
      manifest = JSON.parse(packager.send(:manifest).to_json)
      expected_manifest = {
        "archive_filename" => archive_filename,
        "metadata_filename" => "metadata.json",
        "files" => ["metadata.json", "test.0001.docx", "aperta-generated-PDF.pdf"]
      }
      expect(manifest).to eq expected_manifest
    end

    it 'passed the destination to MetadataTypeseter' do
      expect(Typesetter::MetadataSerializer).to \
        receive(:new).with(paper, destination: 'apex').and_return(metadata_serializer)
      packager = ExportPackager.new(paper, destination: 'apex')
      packager.zip_file
    end

    describe "add_metadata" do
      it "adds a metadata file to the manifest" do
        packager = ExportPackager.new(paper, destination: 'apex')
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_metadata, package)
        end
        metadata_filename =
          packager.send(:manifest).metadata_filename
        expect(metadata_filename).to eq "metadata.json"
        files = packager.send(:manifest).file_list
        expect(files).to eq ["metadata.json"]
      end
    end

    describe "add_manuscript" do
      it "adds a manuscript file to the manifest" do
        packager = ExportPackager.new(paper, destination: 'apex')
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_manuscript, package)
        end
        manuscript_filename = packager.send(:manuscript_filename)
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq [manuscript_filename]
      end
    end

    describe "manifest_file" do
      it "returns a manifest file handle" do
        packager = ExportPackager.new(paper, archive_filename: archive_filename, destination: 'apex')
        manifest = packager.manifest_file
        json = JSON.parse manifest.read
        expected_keys = %w(archive_filename metadata_filename files)
        expect(json).to include *expected_keys
      end
    end
  end

  context 'a paper with figures' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.card.content_for_version(:latest).find_by(ident: 'figures--complies') }
    let!(:answer) do
      FactoryGirl.create(:answer,
                         card_content: figure_question,
                         value: 'true',
                         owner: task,
                         owner_type: 'Task')
    end

    let(:figure) do
      FactoryGirl.create(
        :figure,
        title: 'a figure',
        caption: 'a caption',
        file: File.open(Rails.root.join('spec/fixtures/yeti.jpg'))
      )
    end

    before do
      paper.figures = [figure]
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:read)
        .and_return('a string')
    end

    it 'adds a figure to a zip' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')

      contents = read_zip_entry(zip_io, 'yeti.jpg')
      expect(contents).to eq('a string')
    end

    it 'adds a figure to a zip2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')

      expect(zip_filenames(zip_io)).to include('yeti.jpg')
    end

    describe "add_figures" do
      it "adds figure files to the manifest" do
        packager = ExportPackager.new(paper, destination: 'apex')
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_figures, package)
        end
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq ["yeti.jpg"]
      end
    end
  end

  describe 'add_cover_letter' do
    let(:attachment_file) do
      double('attachment_model', filename: 'cover-letter.docx',
                                 read: 'some bytes')
    end
    let(:question_attachment) { double(QuestionAttachment, filename: 'cover-letter.docx', file: attachment_file) }
    before do
      allow(paper).to receive_message_chain(:question_attachments, :cover_letter) { [question_attachment] }
    end

    it 'adds cover letter files to a zip' do
      zip_io = ExportPackager.create_zip(paper, destination: 'not-apex')

      cover_letter_name = "aperta-cover-letter-#{paper.short_doi}.docx"
      contents = read_zip_entry(zip_io, cover_letter_name)
      expect(contents).to eq('some bytes')
    end

    it 'adds cover letter files to a zip2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'not-apex')

      cover_letter_name = "aperta-cover-letter-#{paper.short_doi}.docx"
      expect(zip_filenames(zip_io)).to include(cover_letter_name)
    end
  end

  context 'a paper with supporting information' do
    let!(:figure_task) do
      paper.tasks.find_by_type('TahiStandardTasks::FigureTask')
    end
    let!(:figure_question) { figure_task.card.content_for_version(:latest).find_by(ident: 'figures--complies') }
    let!(:figure_nested_question_answer) do
      FactoryGirl.create(:answer,
                         card_content: figure_question,
                         value: 'true',
                         owner: figure_task,
                         owner_type: 'Task')
    end

    let(:supporting_information_file) do
      FactoryGirl.create(
        :supporting_information_file,
        title: 'a file',
        caption: 'a caption',
        file: File.open(
          Rails.root.join('spec/fixtures/about_turtles.docx')
        )
      )
    end

    before do
      paper.supporting_information_files = [supporting_information_file]
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:read)
        .and_return('a string')
    end

    it 'adds supporting information to a zip' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      contents = read_zip_entry(zip_io, 'about_turtles.docx')
      expect(contents).to eq('a string')
    end

    it 'adds supporting information to a zip2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(zip_filenames(zip_io)).to include('about_turtles.docx')
    end

    it 'does not add unpublishable supporting information to the zip' do
      supporting_information_file.publishable = false
      supporting_information_file.save!
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')

      expect(zip_filenames(zip_io)).to_not include(
        supporting_information_file.filename
      )
    end

    describe "add_supporting_information" do
      it "adds a SI file to the package" do
        packager = ExportPackager.new(paper, destination: 'apex')
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_supporting_information, package)
        end
        si_filename = "about_turtles.docx"
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq [si_filename]
      end
    end
  end

  context 'a paper with a figure' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.card.content_for_version(:latest).find_by(ident: 'figures--complies') }
    let!(:attachment1) do
      double('attachment_model', filename: 'yeti.jpg',
                                 read: 'some bytes')
    end
    let!(:attachment2) do
      double('attachment_model', filename: 'yeti2.jpg',
                                 read: 'some other bytes')
    end
    let!(:answer) do
      FactoryGirl.create(:answer,
                         card_content: figure_question,
                         value: 'true',
                         owner: task,
                         owner_type: 'Task')
    end

    let(:figure) do
      stub_model(Figure,
                 title: 'a title',
                 caption: 'a caption',
                 paper: paper,
                 filename: 'yeti2.jpg',
                 file: attachment2)
    end

    before do
      allow(paper).to receive(:figures).and_return([figure])
    end

    it 'separates figures' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')

      filenames = zip_filenames(zip_io)
      expect(filenames).to include('yeti2.jpg')
      expect(filenames).to_not include('yeti.jpg')
    end
  end

  context 'a pdf manuscript' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.card.content_for_version(:latest).find_by(ident: 'figures--complies') }
    let!(:answer) do
      FactoryGirl.create(:answer,
        card_content: figure_question,
        value: 'true',
        owner: task,
        owner_type: 'Task')
    end
    let!(:pdf_manuscript_file) do
      instance_double(ManuscriptAttachment, filename: 'manuscript_file.pdf')
    end
    let!(:source_file) do
      instance_double(SourcefileAttachment, filename: 'manuscript_file.docx')
    end

    before do
      allow(paper).to receive(:file).and_return(pdf_manuscript_file)
      allow(paper).to receive(:file_type).and_return('pdf')
      allow(paper).to receive(:sourcefile).and_return(source_file)
      allow(pdf_manuscript_file).to receive(:url)
        .and_return(Rails.root.join('spec/fixtures/about_turtles.pdf'))
      allow(paper).to receive(:file).and_return(pdf_manuscript_file)
      allow(source_file).to receive(:url)
        .and_return(Rails.root.join('spec/fixtures/about_turtles.docx'))
    end

    it 'creates a zip package for a paper with pdf' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(zip_filenames(zip_io)).to include('test.0001.pdf')
    end

    it 'creates a zip package for a paper with pdf2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(
        zip_contains(zip_io, 'test.0001.pdf', Rails.root.join('spec/fixtures/about_turtles.pdf'))
      ).to be(true)
    end

    it 'creates a zip package for a paper with docx' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(
        zip_contains(zip_io, 'test.0001.docx', Rails.root.join('spec/fixtures/about_turtles.docx'))
      ).to be(true)
    end

    it 'creates a zip package for a paper with docx2' do
      zip_io = ExportPackager.create_zip(paper, destination: 'apex')
      expect(zip_filenames(zip_io)).to include('test.0001.docx')
    end
  end
end
