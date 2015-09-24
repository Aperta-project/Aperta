require 'rails_helper'

describe DefaultAuthorCreator do

  describe 'set_default_author' do
    let(:creator) { FactoryGirl.create(:user) }
    let(:phase) { FactoryGirl.create(:phase) }

    it 'Creates an author' do

      expect {
        DefaultAuthorCreator.new(phase.paper, creator).create!
      }.to change(Author, :count).by(1)
    end

    it 'Author created have the same values as creator' do
      DefaultAuthorCreator.new(phase.paper, creator).create!

      author = Author.last
      expect(author.first_name).to eq(creator.first_name)
      expect(author.last_name).to eq(creator.last_name)
      expect(author.email).to eq(creator.email)
      expect(author.paper).to eq(phase.paper)
    end

    it 'Author have the affiliation info from the creator' do
      FactoryGirl.create(
        :affiliation,
        user: creator,
        name: 'Harvard University',
        department: 'Computer Science',
        title: 'Señor Developero'
      )

      DefaultAuthorCreator.new(phase.paper, creator).create!

      author = Author.last

      expect(author.affiliation).to eq('Harvard University')
      expect(author.department).to eq('Computer Science')
      expect(author.title).to eq('Señor Developero')
    end

    it 'Author record has the association with the paper Authors Task' do

      authors_task = TahiStandardTasks::AuthorsTask.create(
        title: "Authors",
        role: "author",
        phase: phase
      )

      DefaultAuthorCreator.new(phase.paper, creator).create!
      author = Author.last

      expect(author.authors_task).to eq(authors_task)
    end
  end
end
