require 'rails_helper'

describe PlosAuthors::PlosAuthor do
  context "validation" do
    it "will be valid with default factory data" do
      model = FactoryGirl.build(:plos_author)
      expect(model).to be_valid
    end

    context "without a paper" do
      let(:plos_author) { FactoryGirl.build(:plos_author, paper: nil) }

      it "fail validation" do
        expect(plos_author.valid?).to eq false
        expect(plos_author.errors.messages).to eq({ paper: ["can't be blank"] })
      end
    end
  end

  describe "Author extensions" do
    it "extends from Author" do
      plos_author = subject.class.create(email: "someone@example.com", first_name: "Someone", paper: FactoryGirl.create(:paper))
      expect(Author.last.specific).to eq(plos_author)
    end

    it "destroys corresponding Author" do
      plos_author = subject.class.create(email: "someone@example.com", first_name: "Someone", paper: FactoryGirl.create(:paper))
      expect {
        plos_author.destroy
      }.to change { Author.count }.by (-1)
    end
  end

  describe "#task_completed?" do
    let(:plos_authors_task) { PlosAuthors::PlosAuthorsTask.new }

    it "is true when task is complete" do
      plos_authors_task.completed = true
      expect(subject.class.new(plos_authors_task: plos_authors_task)).to be_task_completed
    end

    it "is false when task is incomplete" do
      plos_authors_task.completed = false
      expect(subject.class.new(plos_authors_task: plos_authors_task)).to_not be_task_completed
    end

    it "is false when there is no task" do
      expect(subject.class.new(plos_authors_task: nil)).to_not be_task_completed
    end
  end
end
