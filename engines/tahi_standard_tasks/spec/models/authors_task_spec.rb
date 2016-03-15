require 'rails_helper'

describe TahiStandardTasks::AuthorsTask do
  describe "#validate_authors" do
    let(:invalid_author) { FactoryGirl.create(:author, email: nil) }
    let(:valid_author) do
      author = FactoryGirl.create(:author)
      question = author.class.contributions_question
      contribution = question.children.first
      q = author.find_or_build_answer_for(nested_question: contribution)
      q.value = true
      q.save!
      author
    end
    let(:task) { FactoryGirl.create(:authors_task, completed: true) }

    it "hooks up authors via AuthorListItems" do
      valid_author.task = task
      expect(task.reload.authors).to include(valid_author)
    end

    it "validates individual authors" do
      invalid_author.task = task
      expect(task.reload.valid?).to be(false)
      expect(task.errors[:authors][invalid_author.id].messages).to be_present
    end

    it "validates individual authors" do
      valid_author.task = task
      expect(task.reload.valid?).to be(true)
    end
  end
end
