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

describe Author do
  subject(:author) { FactoryGirl.create(:author, paper: paper) }
  let(:authors_task) { FactoryGirl.create(:authors_task, completed: false) }
  let(:paper) { authors_task.paper }

  let!(:contributions_content) do
    FactoryGirl.create(
      :card_content,
      ident: Author::CONTRIBUTIONS_QUESTION_IDENT,
      value_type: "question-set",
      text: "Author Contributions"
    )
  end

  let!(:experiments) do
    FactoryGirl.create(
      :card_content,
      ident: "conceived_and_designed_experiments",
      value_type: "boolean",
      parent: contributions_content,
      text: "Conceived and designed the experiments"
    )
  end

  describe "validation" do
    it "will be valid with default factory data" do
      expect(author).to be_valid
    end

    describe 'email uniqueness' do
      it 'is unique among authors on the paper' do
        dupe_author = FactoryGirl.build(:author, paper: paper, email: author.email)
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end

      it 'is unique among group authors on the paper' do
        group_author = FactoryGirl.create(:group_author, paper: paper)
        dupe_author = FactoryGirl.build(:author, paper: subject.paper, email: group_author.email)
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end

      it 'is validated on email change' do
        dupe_author = FactoryGirl.create(:author, paper: paper, email: "blah#{author.email}")
        expect(dupe_author).to be_valid
        dupe_author.email = author.email
        expect(dupe_author).not_to be_valid
        expect(dupe_author.errors[:email]).to include('Duplicate email address for this manuscript')
      end
    end

    context "and the corresponding authors_task is completed" do
      before do
        allow(author).to receive(:task).and_return(authors_task)
        allow(authors_task).to receive(:completed).and_return(true)
      end

      it "is not valid without contributions" do
        expect(author.contributions.empty?).to be(true)
        expect(author.valid?).to be(false)
      end

      it "is valid with at least one contribution" do
        FactoryGirl.create(
          :answer,
          paper: paper,
          card_content: experiments,
          owner: author
        )
        expect(author.contributions.empty?).to be(false)
        expect(author.valid?).to be(true)
      end
    end

    describe 'stripping whitespace' do
      it 'strips whitespace from first_name, last_name, middle_initial, and email before validation' do
        author = FactoryGirl.build(:author, email: '    author@example.com   ', first_name: '   author', last_name: ' name ', middle_initial: '  A  ')

        expect(author).to be_valid
        expect(author.email).to eq('author@example.com')
        expect(author.first_name).to eq('author')
        expect(author.last_name).to eq('name')
        expect(author.middle_initial).to eq('A')
      end
    end
  end

  describe "#update_coauthor_state" do
    let(:user) { FactoryGirl.create(:user, :site_admin) }
    it "Updates coauthor status" do
      status = "confirmed"
      author.update_coauthor_state(status, user.id)
      author.reload
      expect(author.co_author_state).to eq "confirmed"
      expect(author.co_author_state_modified_at).to be_present
      expect(author.co_author_state_modified_by_id).to eq user.id
    end
  end

  describe "#contributions" do
    let!(:question_that_does_not_belong_to_contributions) do
      FactoryGirl.create(
        :card_content,
        ident: "another--question",
        value_type: "boolean",
        text: "Conceived and designed the experiments"
      )
    end
    let!(:answer_that_should_not_be_included) do
      FactoryGirl.create(
        :answer,
        card_content: question_that_does_not_belong_to_contributions,
        owner: author,
        paper: paper
      )
    end

    context "when there are contributions" do
      let!(:answer_that_should_be_included) do
        FactoryGirl.create(
          :answer,
          card_content: experiments,
          owner: author,
          paper: paper
        )
      end

      it "returns an array of contributions (e.g. any answered question under the contributions question-set)" do
        expect(author.contributions).to eq([answer_that_should_be_included])
      end
    end

    context "when there are no contributions" do
      it "returns an empty array" do
        expect(author.contributions.empty?).to be(true)
      end
    end
  end

  describe "#co_author_confirmed?" do
    it "returns true when co_author_state is 'confirmed'" do
      author.co_author_state = 'confirmed'
      expect(author.co_author_confirmed?).to eq(true)
    end
  end

  describe "#co_author_confirmed!" do
    it "sets co_author_state to confirmed" do
      expect do
        author.co_author_confirmed!
      end.to change { author.co_author_state }.from('unconfirmed').to('confirmed')
    end

    it "sets co_author_state_modified_at" do
      Timecop.freeze do |reference_time|
        expect do
          author.co_author_confirmed!
        end.to change { author.co_author_state_modified_at }.to(reference_time)
      end
    end
  end

  describe "#full_name" do
    it "returns the author's first + last name" do
      author.first_name = "Astronaut"
      author.last_name = "Dog"
      expect(author.full_name).to eq "Astronaut Dog"
    end
  end

  describe "#fully_validate?" do
    let(:authors_task) { FactoryGirl.create(:authors_task, completed: true) }
    let(:author) { FactoryGirl.create(:author, :contributions, paper: authors_task.paper).reload }

    it "is true when task is complete" do
      expect(author.fully_validate?).to be true
    end

    it "is false when task is incomplete" do
      authors_task.update!(completed: false)
      expect(author.fully_validate?).to be_falsy
    end

    it "is false when there is no task" do
      expect(Author.new.fully_validate?).to be_falsy
    end

    it "is true when there's no task but validate_all is true" do
      a = Author.new
      a.validate_all = true
      expect(a.fully_validate?).to be true
    end
  end

  describe "callbacks" do
    context "before_create" do
      describe "#set_default_co_author_state" do
        it "sets a default value of 'unconfirmed' on author creation" do
          expect(author.co_author_state).to eq "unconfirmed"
        end
      end
    end
  end
end
