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
  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

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
