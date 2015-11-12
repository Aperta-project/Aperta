require 'rails_helper'

describe Typesetter::SupportingInformationFileSerializer do
  subject(:serializer) { described_class.new(file) }

  let(:title) { 'My title' }
  let(:caption) { 'My caption' }
  let(:file_name) { 'file_name.csv' }
  let(:file) do
    FactoryGirl.create(
      :supporting_information_file,
      title: title,
      caption: caption)
  end

  let(:output) { serializer.serializable_hash }

  before do
    allow(file.attachment).to receive(:path).and_return('a/b/c/' + file_name)
  end

  it 'has the correct fields' do
    expect(output.keys).to contain_exactly(
      :title,
      :caption,
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
end
