require 'rails_helper'

describe Typesetter::AuthorSerializer do
  subject(:serializer) { described_class.new(author) }

  let(:first_name) { 'first name' }
  let(:last_name) { 'last name' }
  let(:middle_initial) { 'm' }
  let(:email) { 'exampleemail@example.com' }
  let(:department) { 'The Department' }
  let(:title) { 'Best ever' }
  let(:corresponding) { true }
  let(:deceased) { false }
  let(:affiliation) { 'PLOS' }
  let(:secondary_affiliation) { 'SECONDARY AFFILIATION' }

  let!(:author) do
    FactoryGirl.create(
      :author,
      first_name: first_name,
      last_name: last_name,
      middle_initial: middle_initial,
      email: email,
      department: department,
      title: title,
      corresponding: corresponding,
      deceased: deceased,
      affiliation: affiliation,
      secondary_affiliation: secondary_affiliation
    )
  end

  let!(:contributes_question) do
    FactoryGirl.create(
      :nested_question,
      owner_id: nil,
      owner_type: 'Author',
      ident: 'contributions'
    )
  end

  let!(:question1) do
    author.class.contributions_question.children[0]
  end

  let!(:question2) do
    author.class.contributions_question.children[1]
  end

  let!(:answer1) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: question1,
      owner: author,
      value: 't',
      value_type: 'boolean'
    )
  end
  let!(:answer2) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: question2,
      owner: author,
      value: 'f',
      value_type: 'boolean'
    )
  end

  let(:output) { serializer.serializable_hash }

  it 'has author interests fields' do
    expect(output.keys).to contain_exactly(
      :first_name,
      :last_name,
      :middle_initial,
      :email,
      :department,
      :title,
      :corresponding,
      :deceased,
      :affiliation,
      :secondary_affiliation,
      :contributions
    )
  end

  describe 'contributions' do
    it 'is the answer to the competing interests question' do
      expect(output[:contributions]).to eq([question1.text])
    end
  end

  describe 'first_name' do
    it "is the author's first name" do
      expect(output[:first_name]).to eq(first_name)
    end
  end

  describe 'last_name' do
    it "is the author's last name" do
      expect(output[:last_name]).to eq(last_name)
    end
  end

  describe 'middle_initial' do
    it "is the author's middle initial" do
      expect(output[:middle_initial]).to eq(middle_initial)
    end
  end

  describe 'email' do
    it "is the author's email" do
      expect(output[:email]).to eq(email)
    end
  end

  describe 'department' do
    it "is the author's department" do
      expect(output[:department]).to eq(department)
    end
  end

  describe 'title' do
    it "is the author's title" do
      expect(output[:title]).to eq(title)
    end
  end

  describe 'corresponding' do
    it "is the author's corresponding preference" do
      expect(output[:corresponding]).to eq(corresponding)
    end
  end

  describe 'deceased' do
    it 'is the author deceased' do
      expect(output[:deceased]).to eq(deceased)
    end
  end

  describe 'affiliation' do
    it "is the author's affiliation" do
      expect(output[:affiliation]).to eq(affiliation)
    end
  end

  describe 'secondary_affiliation' do
    it "is the author's secondary affiliation" do
      expect(output[:secondary_affiliation]).to eq(secondary_affiliation)
    end
  end
end
