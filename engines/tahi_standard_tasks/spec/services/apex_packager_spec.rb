require 'rails_helper'
require 'zip'

describe ApexPackager do
  let!(:paper) { FactoryGirl.create(:paper, :with_tasks) }

  def zip_contains(package, filename)
    Zip::File.open_buffer(package) do |zip|
      zip.each do |entry|
        return true if entry.name == filename
      end
    end
    false
  end

  context 'a well formed paper' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.find_nested_question('figure_complies') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: figure_question,
                         value: 'true',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end

    it 'creates a zip package for a paper' do
      pending('Check for included DOCX once that is implemented')
      response = ApexPackager.create(paper)

      expect(zip_contains(response, 'doi.docx')).to be(true)
    end
  end

  context 'a paper with figures' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.find_nested_question('figure_complies') }
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
        attachment: File.open(Rails.root.join('spec/fixtures/yeti.jpg')),
        striking_image: false
      )
    end

    before do
      paper.figures = [figure]
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:read)
        .and_return('a string')
    end

    it 'adds a figure to a zip' do
      response = ApexPackager.create(paper)

      expect(zip_contains(response, figure.filename)).to be(true)
    end

    it 'does not add figures that do not comply' do
      nested_question_answer.value = 'false'
      nested_question_answer.save!
      response = ApexPackager.create(paper)

      expect(zip_contains(response, figure.filename)).to be(false)
    end
  end

  context 'a paper with supporting information' do
    let!(:task) do
      paper.tasks.find_by_type('TahiStandardTasks::SupportingInformationTask')
    end
    let!(:figure_question) { task.find_nested_question('figure_complies') }
    let!(:nested_question_answer) do
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
      response = ApexPackager.create(paper)

      expect(zip_contains(response, supporting_information_file.filename)).to \
        be(true)
    end

    it 'does not add unpublishable supporting information to the zip' do
      supporting_information_file.publishable = false
      supporting_information_file.save!
      response = ApexPackager.create(paper)

      expect(zip_contains(response, supporting_information_file.filename)).to \
        be(false)
    end
  end

  context 'a paper with a striking image' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:figure_question) { task.find_nested_question('figure_complies') }
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
                 apex_filename: 'Strikingimage.jpg',
                 attachment: attachment1,
                 striking_image: true)
    end

    let(:figure) do
      stub_model(Figure,
                 title: 'a title',
                 caption: 'a caption',
                 paper: paper,
                 apex_filename: 'yeti2.jpg',
                 attachment: attachment2,
                 striking_image: false)
    end

    let(:figures) { [figure, striking_image] }

    before do
      paper.striking_image = striking_image
      allow(paper).to receive(:figures).and_return(figures)
    end

    it 'includes the strking image with proper name' do
      response = ApexPackager.create(paper)

      expect(zip_contains(response, 'Strikingimage.jpg')).to be(true)
    end

    it 'separates figures and striking images' do
      response = ApexPackager.create(paper)

      expect(zip_contains(response, 'Strikingimage.jpg')).to be(true)
      expect(zip_contains(response, 'yeti2.jpg')).to be(true)
      expect(zip_contains(response, 'yeti.jpg')).to be(false)
    end
  end
end
