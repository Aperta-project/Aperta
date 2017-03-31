require 'rails_helper'

describe Typesetter::SupportingInformationFileSerializer do
  subject(:serializer) { described_class.new(si_file) }

  let(:title_html) { 'My title' }
  let(:caption_html) { 'My caption' }
  let(:label) { 'S3' }
  let(:category) { 'Figure' }
  let(:file_name) { 'file_name.csv' }
  let(:si_file) do
    FactoryGirl.create(
      :supporting_information_file,
      title_html: title_html,
      caption_html: caption_html,
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
      :title_html,
      :caption_html,
      :label,
      :file_name)
  end

  describe 'title_html' do
    it "is the file's title_html" do
      expect(output[:title_html]).to eq(title_html)
    end
  end

  describe 'caption_html' do
    it "is the file's caption_html" do
      expect(output[:caption_html]).to eq(caption_html)
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
