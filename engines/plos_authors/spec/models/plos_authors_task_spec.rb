require 'spec_helper'

describe PlosAuthors::PlosAuthorsTask do
  describe "#validate_authors" do
    let(:invalid_author) { FactoryGirl.build_stubbed(:plos_author, email: nil) }
    let(:valid_author) { FactoryGirl.build_stubbed(:plos_author) }
    let(:task) { PlosAuthors::PlosAuthorsTask.new(completed: true, title: "Add Authors", role: "author", plos_authors: [invalid_author, valid_author] ) }

    it "validates individual plos authors" do
      expect(task).to_not be_valid
      expect(task.errors[:plos_authors].size).to eq(1)
      expect(task.errors[:plos_authors][invalid_author.id].messages).to be_present
    end
  end
end

