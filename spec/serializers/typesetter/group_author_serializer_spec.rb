require 'rails_helper'

describe Typesetter::GroupAuthorSerializer do
  before do
    CardLoader.load('GroupAuthor')
  end

  subject(:serializer) { described_class.new(group_author) }

  let(:contact_first_name) { 'first name' }
  let(:contact_last_name) { 'last name' }
  let(:contact_middle_name) { 'middle' }
  let(:contact_email) { 'exampleemail@example.com' }
  let(:group_name) { 'group name' }

  let!(:group_author) do
    FactoryGirl.create(
      :group_author,
      name: group_name,
      contact_first_name: contact_first_name,
      contact_last_name: contact_last_name,
      contact_middle_name: contact_middle_name,
      contact_email: contact_email
    )
  end

  let(:question1) do
    group_author.class.contributions_content.children[0]
  end

  let(:question2) do
    group_author.class.contributions_content.children[1]
  end

  let!(:answer1) do
    FactoryGirl.create(
      :answer,
      card_content: question1,
      owner: group_author,
      paper: group_author.paper,
      value: true
    )
  end

  let!(:answer2) do
    FactoryGirl.create(
      :answer,
      card_content: question2,
      owner: group_author,
      paper: group_author.paper,
      value: false
    )
  end

  let(:output) { serializer.serializable_hash }

  it 'has author interests fields' do
    expect(output.keys).to contain_exactly(
      :contact_first_name,
      :contact_last_name,
      :contact_middle_name,
      :contact_email,
      :name,
      :contributions,
      :government_employee,
      :type
    )
  end

  describe 'contributions' do
    it 'includes question text when the answer is true' do
      expect(output[:contributions]).to include(question1.text)
    end
    it 'does not include question text when the answer is false' do
      expect(output[:contributions]).to_not include(question2.text)
    end
  end

  describe 'contact_first_name' do
    it "is the group contact's first name" do
      expect(output[:contact_first_name]).to eq(contact_first_name)
    end
  end

  describe 'contact_last_name' do
    it "is the group contact's last name" do
      expect(output[:contact_last_name]).to eq(contact_last_name)
    end
  end

  describe 'contact_middle_name' do
    it "is the group author contact's middle name" do
      expect(output[:contact_middle_name]).to eq(contact_middle_name)
    end
  end

  describe 'contact_email' do
    it "is the contact's email" do
      expect(output[:contact_email]).to eq(contact_email)
    end
  end

  describe 'government_employee' do
    before do
      allow(group_author).to receive(:answer_for)
        .with(::GroupAuthor::GOVERNMENT_EMPLOYEE_QUESTION_IDENT)
        .and_return instance_double(Answer, value: true)
    end

    it 'includes whether or not the author is a government employee' do
      expect(output[:government_employee]).to be true
    end
  end

  describe 'name' do
    before { group_author.name = 'bob' }
    it 'includes the name of the author' do
      expect(output[:name]).to eq('bob')
    end
  end

  describe 'type' do
    it 'has a type of group_author' do
      expect(output[:type]).to eq 'group_author'
    end
  end
end
