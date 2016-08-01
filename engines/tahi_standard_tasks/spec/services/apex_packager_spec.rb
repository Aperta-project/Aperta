require 'rails_helper'

describe ApexPackager do
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }
  let!(:latest_version) do
    FactoryGirl.create(:versioned_text,
                       paper: paper,
                       major_version: 0,
                       minor_version: 1)
  end
  let!(:source) { double(File) }
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
        return io.read if (entry.name == file_name)
      end
    end
    nil
  end

  def zip_contains(zip_io, file_in_zip, expected_path)
    expected_contents = File.open(expected_path, 'rb', &:read)
    expected_contents == read_zip_entry(zip_io, file_in_zip)
  end

  before do
    allow(paper).to receive(:latest_version).and_return(latest_version)
    allow(paper).to receive(:manuscript_id).and_return('test.0001')
    allow(latest_version).to receive(:source_url).and_return(
      Rails.root.join('spec/fixtures/about_turtles.docx'))
    allow(latest_version).to receive(:source).and_return(
      source)
    allow(source).to receive(:path).and_return('about_turtles.docx')

    metadata_serializer = instance_double('Typesetter::MetadataSerializer')
    allow(metadata_serializer).to receive(:to_json).and_return('json')
    allow(Typesetter::MetadataSerializer).to \
      receive(:new).and_return(metadata_serializer)
  end

  context 'a well formed paper' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.nested_questions.find_by(ident: 'figures--complies') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end

    it 'creates a zip package for a paper' do
      zip_io = ApexPackager.create_zip(paper)
      expect(zip_filenames((zip_io))).to include(
        'test.0001.docx')
      expect(zip_contains(zip_io,
                          'test.0001.docx',
                          Rails.root.join(
                            'spec/fixtures/about_turtles.docx'))).to be(true)
    end

    it 'contains the correct metadata' do
      zip_io = ApexPackager.create_zip(paper)
      contents = read_zip_entry(zip_io, 'metadata.json')
      expect(contents).to eq('json')
    end

    it 'creates a valid manifest' do
      packager = ApexPackager.new(paper, archive_filename: archive_filename)
      packager.zip_file
      manifest = JSON.parse(packager.send(:manifest).to_json)
      expected_manifest = {
        "archive_filename" => archive_filename,
        "metadata_filename" => "metadata.json",
        "files" => ["metadata.json", "test.0001.docx"]
      }
      expect(manifest).to eq expected_manifest
    end

    describe "add_metadata" do
      it "adds a manuscript file to the manifest" do
        packager = ApexPackager.new(paper)
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
        packager = ApexPackager.new(paper)
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
        packager = ApexPackager.new(paper, archive_filename: archive_filename)
        manifest = packager.manifest_file
        json = JSON.parse manifest.read
        expected_keys = %w(archive_filename metadata_filename files)
        expect(json).to include *expected_keys
      end
    end
  end

  context 'a paper with figures' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.nested_questions.find_by(ident: 'figures--complies') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
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
      zip_io = ApexPackager.create_zip(paper)

      expect(zip_filenames((zip_io))).to include('yeti.jpg')
      contents = read_zip_entry(zip_io, 'yeti.jpg')
      expect(contents).to eq('a string')
    end

    it 'does not add a striking image when none is present' do
      zip_io = ApexPackager.create_zip(paper)

      expect(zip_filenames((zip_io))).to_not include('Strikingimage.jpg')
    end

    describe "add_figures" do
      it "adds figure files to the manifest" do
        packager = ApexPackager.new(paper)
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_figures, package)
        end
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq ["yeti.jpg"]
      end
    end
  end

  context 'a paper with supporting information' do
    let!(:task) do
      paper.tasks.find_by_type('TahiStandardTasks::SupportingInformationTask')
    end
    let!(:figure_question) { task.nested_questions.find_by(ident: 'figures--complies') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end
    let!(:figure_task) do
      paper.tasks.find_by_type('TahiStandardTasks::FigureTask')
    end
    let!(:figure_question) { task.nested_questions.find_by(ident: 'figures--complies') }
    let!(:figure_nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
                         owner: task,
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
      zip_io = ApexPackager.create_zip(paper)

      expect(zip_filenames((zip_io))).to include('about_turtles.docx')
      contents = read_zip_entry(zip_io, 'about_turtles.docx')
      expect(contents).to eq('a string')
    end

    it 'does not add unpublishable supporting information to the zip' do
      supporting_information_file.publishable = false
      supporting_information_file.save!
      zip_io = ApexPackager.create_zip(paper)

      expect(zip_filenames((zip_io))).to_not include(
        supporting_information_file.filename)
    end

    describe "add_supporting_information" do
      it "adds a SI file to the package" do
        packager = ApexPackager.new(paper)
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_supporting_information, package)
        end
        si_filename = "about_turtles.docx"
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq [si_filename]
      end
    end
  end

  context 'a paper with a striking image' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.nested_questions.find_by(ident: 'figures--complies') }
    let!(:attachment1) do
      double('attachment_model', filename: 'yeti.jpg',
                                 read: 'some bytes')
    end
    let!(:attachment2) do
      double('attachment_model', filename: 'yeti2.jpg',
                                 read: 'some other bytes')
    end
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end

    let(:striking_image) do
      stub_model(Figure,
                 title: 'a figure',
                 caption: 'a caption',
                 paper: paper,
                 filename: 'yeti1.jpg',
                 file: attachment1)
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
      paper.striking_image = striking_image
      allow(paper).to receive(:figures).and_return([figure, striking_image])
    end

    it 'includes the strking image with proper name' do
      zip_io = ApexPackager.create_zip(paper)
      expect(zip_filenames(zip_io)).to include('Strikingimage.jpg')
    end

    it 'separates figures and striking images' do
      zip_io = ApexPackager.create_zip(paper)

      filenames = zip_filenames(zip_io)
      expect(filenames).to include('Strikingimage.jpg')
      expect(filenames).to include('yeti2.jpg')
      expect(filenames).to_not include('yeti.jpg')
    end

    describe "add_stricking_image" do
      it "adds a stricking image to the manifest" do
        packager = ApexPackager.new(paper)
        Zip::OutputStream.open(zip_file) do |package|
          packager.send(:add_striking_image, package)
        end
        striking_image_filename =
          packager.send(:attachment_apex_filename, paper.striking_image)
        file_list = packager.send(:manifest).file_list
        expect(file_list).to eq [striking_image_filename]
      end
    end
  end
end
