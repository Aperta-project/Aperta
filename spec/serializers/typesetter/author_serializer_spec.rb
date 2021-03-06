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

describe Typesetter::AuthorSerializer do
  before do
    CardLoader.load('Author')
  end

  subject(:serializer) { described_class.new(author, options) }
  let!(:options) { { destination: "em", unique_values: {} } }

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

  let(:user) { FactoryGirl.create(:user) }

  let(:contributes_question) do
    CardContent.find_by(ident: "author--contributions")
  end

  let(:question1) do
    author.class.contributions_content.children[0]
  end

  let(:question2) do
    author.class.contributions_content.children[1]
  end

  let!(:deceased_question) do
    CardContent.find_by_ident('author--deceased')
  end

  let!(:answer1) do
    FactoryGirl.create(
      :answer,
      card_content: question1,
      owner: author,
      paper: author.paper,
      value: true
    )
  end

  let!(:answer2) do
    FactoryGirl.create(
      :answer,
      card_content: question2,
      owner: author,
      paper: author.paper,
      value: false
    )
  end

  let!(:deceased_answer) do
    FactoryGirl.create(
      :answer,
      card_content: deceased_question,
      owner: author,
      paper: author.paper,
      value: true
    )
  end

  let(:output) { serializer.serializable_hash }

  before do
    allow(author).to receive(:answer_for).and_call_original
  end

  let!(:apex_html_flag) do
    FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false
  end

  it 'includes author fields' do
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
      :type,
      :creator
    )
  end

  before do
    allow(author.paper).to receive(:creator).and_return(user)
  end

  describe 'contributions' do
    it 'includes question text when the answer is true' do
      expect(output[:contributions]).to include(question1.text)
    end

    it 'does not include question text when the answer is false' do
      expect(output[:contributions]).to_not include(question2.text)
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

      it 'is true' do
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

      it 'is false' do
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

  describe 'government_employee' do
    before do
      allow(author).to receive(:answer_for)
        .with(::Author::GOVERNMENT_EMPLOYEE_QUESTION_IDENT)
        .and_return instance_double(Answer, value: true)
    end

    it 'includes whether or not the author is a government employee' do
      expect(output[:government_employee]).to be true
    end
  end

  describe 'secondary_affiliation' do
    it "is the author's secondary affiliation" do
      expect(output[:secondary_affiliation]).to eq(secondary_affiliation)
    end
  end

  describe 'type' do
    it 'has a type of author' do
      expect(output[:type]).to eq 'author'
    end
  end

  describe 'creator' do
    context 'author is the creator of the paper' do
      it 'is true' do
        author.user = paper.creator
        expect(output[:creator]).to eq true
      end
    end

    context 'author is not the creator of the paper' do
      it 'is false' do
        author.user = FactoryGirl.create(:user)
        expect(output[:creator]).to eq false
      end
    end

    context 'exporting to apex' do
      let!(:options) { { destination: "apex", unique_values: {} } }
      it 'is not serialized' do
        author.user = FactoryGirl.create(:user)
        expect(output[:creator]).not_to be_present
      end
    end
  end

  describe 'OrcidAccount fields' do
    let(:orcid_account) { FactoryGirl.build_stubbed(:orcid_account, user: user) }
    before do
      allow(author).to receive(:user).and_return(user)
      allow(user).to receive(:orcid_account).and_return(orcid_account)
    end

    context 'when ORCID_CONNECT_ENABLED is true' do
      around do |example|
        ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
          example.run
        end
      end

      context 'author has an OrcidAccount associated' do
        let(:orcid_account) do
          FactoryGirl.build_stubbed(:orcid_account,
            identifier: '0000-0001-0002-0003',
            access_token: 'has_access_token'
          )
        end

        describe 'orcid_profile_url' do
          it 'returns the profile url' do
            expect(output[:orcid_profile_url])
              .to eq('http://sandbox.orcid.org/0000-0001-0002-0003')
          end
        end

        describe 'orcid_authenticated' do
          it 'returns true' do
            expect(output[:orcid_authenticated]).to eq true
          end

          it 'returns false if access token is nil' do
            orcid_account.access_token = nil
            expect(output[:orcid_authenticated]).to eq false
          end
        end
      end

      context 'author does not have an OrcidAccount associated' do
        describe 'orcid_profile_url' do
          it 'returns the profile url' do
            expect(output[:orcid_profile_url]).to be_nil
          end
        end

        describe 'orcid_authenticated' do
          it 'returns false' do
            expect(output[:orcid_authenticated]).to eq false
          end
        end
      end
    end

    context 'when ORCID_CONNECT_ENABLED is false' do
      around do |example|
        ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
          example.run
        end
      end

      it 'does not include orcid_profile_url' do
        expect(output).to_not have_key(:orcid_profile_url)
      end

      it 'does not include orcid_authenticated' do
        expect(output).to_not have_key(:orcid_authenticated)
      end
    end
  end
end
