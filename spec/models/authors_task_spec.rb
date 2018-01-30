require 'rails_helper'

describe AuthorsTask do
  before do
    CardLoader.load('AuthorsTask')
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
