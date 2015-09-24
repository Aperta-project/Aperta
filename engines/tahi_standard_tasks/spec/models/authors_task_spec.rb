require 'rails_helper'

describe TahiStandardTasks::AuthorsTask do

  context "Callbacks" do
    describe 'set_default_author' do
      let(:phase) { FactoryGirl.create(:phase) }
      let(:creator) { FactoryGirl.create(:user) }
      let(:authors_task) { TahiStandardTasks::AuthorsTask.new(title: "Authors", role: "author", phase: phase) }

      it 'creates an author from the initial participant' do
        authors_task.participants << creator

        expect {
          authors_task.save
        }.to change(Author, :count).by(1)
      end

      it 'Author have the same values as creator' do
        authors_task.participants << creator
        authors_task.save

        author = authors_task.authors.last
        expect(author.first_name).to eq(creator.first_name)
        expect(author.last_name).to eq(creator.last_name)
        expect(author.email).to eq(creator.email)
        expect(author.paper).to eq(phase.paper)
      end

      it 'Author have the affiliation as the creator' do
        affiliation = FactoryGirl.create(:affiliation,
                                        user: creator,
                                        name: 'Harvard University',
                                        department: 'Computer Science',
                                        title: 'Señor Developero')
        authors_task.participants << creator
        authors_task.save
        author = authors_task.authors.last

        expect(author.affiliation).to eq('Harvard University')
        expect(author.department).to eq('Computer Science')
        expect(author.title).to eq('Señor Developero')
      end
    end
  end

  context "Validations" do
    describe "#validate_authors" do
      let(:invalid_author) { FactoryGirl.build_stubbed(:author, email: nil) }
      let(:valid_author) { FactoryGirl.build_stubbed(:author) }
      let(:task) { TahiStandardTasks::AuthorsTask.new(completed: true, title: "Authors", role: "author", authors: [invalid_author, valid_author]) }

      it "validates individual authors" do
        expect(task).to_not be_valid
        expect(task.errors[:authors][invalid_author.id].messages).to be_present
      end
    end
  end
end
