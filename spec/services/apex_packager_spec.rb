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
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: task.nested_questions.first,
                         value: 't',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end

    it 'creates a zip package for a paper' do
      download = ApexPackager.new(paper)
      response = download.export

      expect(response).not_to be_empty
    end
  end

  context 'a paper with figures' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: task.nested_questions.first,
                         value: 't',
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
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, figure.filename)).to be_truthy
    end

    it 'does not add figures that do not comply' do
      nested_question_answer.value = 'f'
      nested_question_answer.save!
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, figure.filename)).to be_falsey
    end
  end

  context 'a paper with supporting information' do
    let!(:task) do
      paper.tasks.find_by_type('TahiStandardTasks::SupportingInformationTask')
    end

    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: task.nested_questions.first,
                         value: 't',
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
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, supporting_information_file.filename)).to \
        be_truthy
    end

    it 'does not add unpublishable supporting information to the zip' do
      supporting_information_file.publishable = false
      supporting_information_file.save!
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, supporting_information_file.filename)).to \
        be_falsey
    end
  end

  context 'a paper with a striking image' do
    let!(:task) { paper.tasks.find_by_type('TahiStandardTasks::FigureTask') }
    let!(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer,
                         nested_question: task.nested_questions.first,
                         value: 't',
                         value_type: 'boolean',
                         owner: task,
                         owner_type: 'Task')
    end

    let(:striking_image) do
      FactoryGirl.create(
        :figure,
        title: 'a figure',
        caption: 'a caption',
        attachment: File.open(Rails.root.join('spec/fixtures/yeti.jpg'))
      )
    end

    let(:figure) do
      FactoryGirl.create(
        :figure,
        title: 'a figure',
        caption: 'a caption',
        attachment: File.open(Rails.root.join('spec/fixtures/yeti2.jpg'))
      )
    end

    before do
      paper.striking_image = striking_image
      paper.figures = [figure]
      allow_any_instance_of(CarrierWave::Storage::Fog::File).to receive(:read)
        .and_return('a string')
    end

    it 'includes the strking image with proper name' do
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, 'Strikingimage.jpg')).to be_truthy
    end

    it 'separates figures and striking images' do
      download = ApexPackager.new(paper)
      response = download.export

      expect(zip_contains(response, 'Strikingimage.jpg')).to be_truthy
      expect(zip_contains(response, 'yeti2.jpg')).to be_truthy
      expect(zip_contains(response, 'yeti.jpg')).to be_falsey
    end
  end
end
