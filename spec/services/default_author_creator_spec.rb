# coding: utf-8
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

# coding: utf-8
require 'rails_helper'

describe DefaultAuthorCreator do
  describe '#create!' do
    let(:creator) { FactoryGirl.build_stubbed(:user) }
    let(:paper) { FactoryGirl.create(:paper_with_phases) }

    before do
      CardLoader.load("Author")
    end

    it 'creates an author on the paper' do
      expect do
        DefaultAuthorCreator.new(paper, creator).create!
      end.to change { paper.authors.count }.by(1)
    end

    it 'links the creator with the author' do
      author = DefaultAuthorCreator.new(paper, creator).create!
      expect(author.user).to eq creator
    end

    it 'populates the author with values from the creator' do
      author = DefaultAuthorCreator.new(paper, creator).create!
      expect(author.first_name).to eq(creator.first_name)
      expect(author.last_name).to eq(creator.last_name)
      expect(author.email).to eq(creator.email)
      expect(author.paper).to eq(paper)
    end

    it <<-DESC do
      sets the author affiliation information to the creator's
      first affiliation
    DESC
      FactoryGirl.create(
        :affiliation,
        user: creator,
        name: 'Harvard University',
        department: 'Computer Science',
        title: 'Señor Developero'
      )

      author = DefaultAuthorCreator.new(paper, creator).create!
      expect(author.affiliation).to eq('Harvard University')
      expect(author.department).to eq('Computer Science')
      expect(author.title).to eq('Señor Developero')
    end

    it 'associates the author with the AuthorsTask on the paper' do
      authors_task = FactoryGirl.create(
        :authors_task,
        :with_loaded_card,
        title: "Authors",
        paper: paper,
        phase: paper.phases.first
      )

      expect do
        author = DefaultAuthorCreator.new(paper, creator).create!
        expect(author).to be_valid
        # the author.reload call below is only a fix for the test environment.
        expect(author.reload.task).to eq(authors_task)
      end.to change { authors_task.authors.count }.by(1)
    end
  end
end
