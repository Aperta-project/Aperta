require 'rails_helper'

describe Typesetter::AuthorSerializer do
  subject(:serializer) { described_class.new(author) }

  let(:first_name) { 'first name' }
  let(:last_name) { 'last name' }
  let(:middle_initial) { 'm' }
  let(:email) { 'exampleemail@example.com' }
  let(:department) { 'The Department' }
  let(:title) { 'Best ever' }
  let(:affiliation) { 'PLOS' }
  let(:secondary_affiliation) { 'SECONDARY AFFILIATION' }

  let(:paper) { FactoryGirl.create(:paper) }
  let!(:author) do
    FactoryGirl.create(
      :author,
      paper: paper,
      first_name: first_name,
      last_name: last_name,
      middle_initial: middle_initial,
      email: email,
      department: department,
      title: title,
      affiliation: affiliation,
      secondary_affiliation: secondary_affiliation
    )
  end

  let!(:contributes_question) do
    NestedQuestion.find_by(ident: "author--contributions") ||
      FactoryGirl.create(
        :nested_question,
        owner_id: nil,
        owner_type: 'Author',
        ident: 'author--contributions'
      )
  end

  let!(:question1) do
    author.class.contributions_question.children[0]
  end

  let!(:question2) do
    author.class.contributions_question.children[1]
  end

  let!(:question3) do
    author.class.contributions_question.children.find_by_ident('other')
  end

  let!(:deceased_question) do
    author.nested_questions.find_by_ident('author--deceased')
  end

  let!(:corresponding_question) do
    author.nested_questions.find_by_ident('author--published_as_corresponding_author')
  end

  let!(:answer1) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: question1,
      owner: author,
      value: true,
      value_type: 'boolean'
    )
  end
  let!(:answer2) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: question2,
      owner: author,
      value: false,
      value_type: 'boolean'
    )
  end
  let!(:answer3) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: question2,
      owner: author,
      value: 'Performed some other duty',
      value_type: 'text'
    )
  end
  let!(:deceased_answer) do
    FactoryGirl.create(
      :nested_question_answer,
      nested_question: deceased_question,
      owner: author,
      value: true,
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
      :contributions,
      :government_employee,
      :type
    )
  end

  before do
    allow(author.paper).to receive(:creator).and_return(FactoryGirl.create(:user))
  end

  describe 'contributions' do
    it 'includes question text when the answer is true' do
      expect(output[:contributions]).to include(question1.text)
    end
    it 'does not include question text when the answer is false' do
      expect(output[:contributions]).to_not include(question2.text)
    end
    it 'includes the `other` text if answered' do
      expect(output[:contributions]).to include(answer3.value)
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
    context <<-DESC.strip_heredoc do
      when the author's email is in the paper's corresponding_author_emails
    DESC

      before do
        allow(paper).to receive(:corresponding_author_emails)
          .and_return [author.email]
      end

      it 'is true'do
        expect(output[:corresponding]).to eq(true)
      end
    end

    context <<-DESC.strip_heredoc do
      when the author's email is not in the paper's corresponding_author_emails
    DESC

      before do
        allow(paper).to receive(:corresponding_author_emails)
          .and_return ['some-other-email@example.com']
      end

      it 'is false'do
        expect(output[:corresponding]).to eq(false)
      end
    end
  end

  describe 'deceased' do
    it 'is the author deceased' do
      expect(output[:deceased]).to eq(deceased_answer.value)
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
