require 'rails_helper'

describe Typesetter::SupportingInformationFileSerializer do
  subject(:serializer) { described_class.new(si_file) }

  let(:title) { 'My title' }
  let(:caption) { 'My caption' }
  let(:label) { 'S3' }
  let(:category) { 'Figure' }
  let(:file_name) { 'file_name.csv' }
  let(:si_file) do
    FactoryGirl.create(
      :supporting_information_file,
      title: title,
      caption: caption,
      label: label,
      category: category
    )
  end

  let(:output) { serializer.serializable_hash }

  before do
    allow(si_file).to receive(:filename).and_return(file_name)
  end

  it 'has the correct fields' do
    expect(output.keys).to contain_exactly(
      :title,
      :caption,
      :label,
      :file_name)
  end

  describe 'title' do
    it "is the file's title" do
      expect(output[:title]).to eq(title)
    end
  end

  describe 'caption' do
    it "is the file's caption" do
      expect(output[:caption]).to eq(caption)
    end
  end

  describe 'file_name' do
    it "is the file's file_name" do
      expect(output[:file_name]).to eq('file_name.csv')
    end
  end

  describe 'label' do
    it "is the file's label plus its category" do
      expect(output[:label]).to eq(label + ' ' + category)
    end
  end
end
