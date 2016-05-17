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

  def zip_filenames(package)
    filenames = []
    Zip::File.open(package) do |zip|
      filenames = zip.map(&:name)
    end
    filenames
  end

  def zip_contains(zip_path, file_in_zip, expected_path)
    expected_contents = File.open(expected_path, 'rb', &:read)
    zip_contents = Zip::File.open(zip_path).read(file_in_zip)

    expected_contents == zip_contents
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
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames((zip_file_path))).to include(
        'test.0001.docx')
      expect(zip_contains(zip_file_path,
                          'test.0001.docx',
                          Rails.root.join(
                            'spec/fixtures/about_turtles.docx'))).to be(true)
    end

    it 'contains the correct metadata' do
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      contents = Zip::File.open(zip_file_path).read('metadata.json')
      expect(contents).to eq('json')
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
        attachment: File.open(Rails.root.join('spec/fixtures/yeti.jpg'))
      )
    end

    before do
      paper.figures = [figure]
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:read)
        .and_return('a string')
    end

    it 'adds a figure to a zip' do
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames((zip_file_path))).to include('yeti.jpg')
      contents = Zip::File.open(zip_file_path).read('yeti.jpg')
      expect(contents).to eq('a string')
    end

    it 'does not add a striking image when none is present' do
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames((zip_file_path))).to_not include('Strikingimage.jpg')
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
        attachment: File.open(
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
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames((zip_file_path))).to include('about_turtles.docx')
      contents = Zip::File.open(zip_file_path).read('about_turtles.docx')
      expect(contents).to eq('a string')
    end

    it 'does not add unpublishable supporting information to the zip' do
      supporting_information_file.publishable = false
      supporting_information_file.save!
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames((zip_file_path))).to_not include(
        supporting_information_file.filename)
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
                 attachment: attachment1)
    end

    let(:figure) do
      stub_model(Figure,
                 title: 'a title',
                 caption: 'a caption',
                 paper: paper,
                 filename: 'yeti2.jpg',
                 attachment: attachment2)
    end

    before do
      paper.striking_image = striking_image
      allow(paper).to receive(:figures).and_return([figure, striking_image])
    end

    it 'includes the strking image with proper name' do
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames(zip_file_path)).to include('Strikingimage.jpg')
    end

    it 'separates figures and striking images' do
      packager = ApexPackager.create(paper)
      zip_file_path = packager.zip_file.path

      expect(zip_filenames(zip_file_path)).to include('Strikingimage.jpg')
      expect(zip_filenames(zip_file_path)).to include('yeti2.jpg')
      expect(zip_filenames(zip_file_path)).to_not include('yeti.jpg')
    end
  end
end
