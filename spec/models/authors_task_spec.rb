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

describe TahiStandardTasks::AuthorsTask do
  before do
    CardLoader.load('TahiStandardTasks::AuthorsTask')
    CardLoader.load('Author')
  end

  it_behaves_like 'is a metadata task'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#validate_authors" do
    let!(:valid_author) do
      author = FactoryGirl.create(:author, paper: task.paper)
      question = Author.contributions_content
      contribution = question.children.first
      contribution.answers.find_or_create_by(owner: author, value: true, paper: task.paper)
      author
    end

    let(:task) { FactoryGirl.create(:authors_task) }

    it "hooks up authors via AuthorListItems" do
      expect(task.reload.authors).to include(valid_author)
    end

    it "validates individual authors" do
      invalid_author = FactoryGirl.create(
        :author,
        email: nil,
        paper: task.paper
      )

      task.update(completed: true)

      expect(task.valid?).to be(false)
      expect(task.errors[:authors][invalid_author.id].messages).to be_present
    end

    it "validates individual authors when it's been completed but not persisted" do
      invalid_author = FactoryGirl.create(
        :author,
        email: nil,
        paper: task.paper
      )

      task.completed = true

      expect(task.valid?).to be(false)
      expect(task.errors[:authors][invalid_author.id].messages).to be_present
    end
  end
end
