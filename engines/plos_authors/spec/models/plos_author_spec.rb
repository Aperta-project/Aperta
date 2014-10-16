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
end

