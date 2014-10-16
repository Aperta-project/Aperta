require 'spec_helper'

describe PlosAuthors::PlosAuthor do
  describe "Author extensions" do
    it "extends from Author" do
      plos_author = subject.class.create(email: "someone@example.com", first_name: "Someone")
      expect(Author.last.specific).to eq(plos_author)
    end

    it "destroys corresponding Author" do
      plos_author = subject.class.create(email: "someone@example.com", first_name: "Someone")
      expect {
        plos_author.destroy
      }.to change { Author.count }.by (-1)
    end
  end

  describe "validations" do
    let(:plos_authors_task) { PlosAuthors::PlosAuthorsTask.new }

    it "will not be valid if the task is completed" do
      plos_authors_task.completed = true
      expect(subject.class.new(email: nil, plos_authors_task: plos_authors_task)).to_not be_valid
    end

    it "will be valid if the task is not complete" do
      plos_authors_task.completed = false
      expect(subject.class.new(email: nil, plos_authors_task: plos_authors_task)).to be_valid
    end
  end
end

