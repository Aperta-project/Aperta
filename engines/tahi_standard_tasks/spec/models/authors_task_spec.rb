require 'rails_helper'

describe TahiStandardTasks::AuthorsTask do
  describe "#validate_authors" do
    let(:invalid_author) { FactoryGirl.build_stubbed(:author, email: nil) }
    let(:valid_author) { FactoryGirl.build_stubbed(:author) }
    let(:task) { TahiStandardTasks::AuthorsTask.new(completed: true, title: "Authors", role: "author", authors: [invalid_author, valid_author] ) }

    it "validates individual authors" do
      expect(task).to_not be_valid
      expect(task.errors[:authors][invalid_author.id].messages).to be_present
    end
  end
end
