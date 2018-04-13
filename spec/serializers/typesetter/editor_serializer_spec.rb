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
describe Typesetter::EditorSerializer do
  let!(:academic_editor) do
    FactoryGirl.create(
      :user,
      first_name: first_name,
      last_name: last_name,
      email: email
    )
  end
  let(:first_name) { 'Bob' }
  let(:last_name) { 'Ross' }
  let(:email) { 'happytrees@example.com' }

  shared_examples 'editor fields' do
    describe 'first_name' do
      it "is the editor's first_name" do
        expect(output[:first_name]).to eq(first_name)
      end
    end
    describe 'last_name' do
      it "is the editor's last_name" do
        expect(output[:last_name]).to eq(last_name)
      end
    end
    describe 'email' do
      it "is the editor's email" do
        expect(output[:email]).to eq(email)
      end
    end
  end

  subject(:serializer) { described_class.new(academic_editor) }
  let(:output) { serializer.serializable_hash }

  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }

  context 'no affiliation' do
    it_behaves_like 'editor fields'

    it 'has nil values for fields related to affiliation' do
      %w(department title organization).each do |field_name|
        expect(output[field_name.to_sym]).to be(nil)
      end
    end
  end

  context 'with affiliation' do
    it_behaves_like 'editor fields'
    let!(:affiliation) do
      FactoryGirl.create(
        :affiliation,
        user: academic_editor,
        name: affiliation_name,
        title: affiliation_title,
        department: affiliation_department,
        country: affiliation_country
      )
    end
    let(:affiliation_name) { 'PBS' }
    let(:affiliation_title) { 'Artist' }
    let(:affiliation_department) { 'Art' }
    let(:affiliation_country) { 'USA' }

    describe 'organization' do
      it "is the editor's organization" do
        expect(output[:organization]).to eq(affiliation_name)
      end
    end

    describe 'title' do
      it "is the editor's title" do
        expect(output[:title]).to eq(affiliation_title)
      end
    end

    describe 'department' do
      it "is the editor's department" do
        expect(output[:department]).to eq(affiliation_department)
      end
    end

    describe 'country' do
      it "is the editor's country" do
        expect(output[:organization_country]).to eq(affiliation_country)
      end
    end
  end
end
