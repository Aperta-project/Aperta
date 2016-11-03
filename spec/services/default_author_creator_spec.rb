# coding: utf-8
require 'rails_helper'

describe DefaultAuthorCreator do

  describe '#create!' do
    let(:creator) { FactoryGirl.build_stubbed(:user) }
    let(:paper) { FactoryGirl.create(:paper_with_phases) }

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
      authors_task = TahiStandardTasks::AuthorsTask.create(
        title: "Authors",
        old_role: "author",
        paper: paper,
        phase: paper.phases.first
      )

      expect do
        author = DefaultAuthorCreator.new(paper, creator).create!
        expect(author.task).to eq(authors_task)
      end.to change { authors_task.authors.count }.by(1)
    end
  end
end
