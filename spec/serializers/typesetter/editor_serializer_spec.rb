require 'rails_helper'
RSpec.shared_examples 'editor fields' do
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

describe Typesetter::EditorSerializer do
  subject(:serializer) { described_class.new(academic_editor) }
  let(:output) { serializer.serializable_hash }

  context 'no affiliation' do
    include_examples 'editor fields'

    it 'has nil values for fields related to affiliation' do
      %w(department title organization).each do |field_name|
        expect(output[field_name.to_sym]).to be(nil)
      end
    end
  end

  context 'with affiliation' do
    include_examples 'editor fields'
    let!(:affiliation) do
      FactoryGirl.create(
        :affiliation,
        user: academic_editor,
        name: affiliation_name,
        title: affiliation_title,
        department: affiliation_department
      )
    end
    let(:affiliation_name) { 'PBS' }
    let(:affiliation_title) { 'Artist' }
    let(:affiliation_department) { 'Art' }

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
  end
end
