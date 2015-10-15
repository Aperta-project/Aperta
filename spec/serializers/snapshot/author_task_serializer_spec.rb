require "rails_helper"

describe Snapshot::AuthorTaskSerializer do
  let(:task) { FactoryGirl.create(:authors_task) }

  describe "serializes authors" do
    def find_property properties, name
      properties.select { |p| p[:name] == name }.first[:value]
    end

    it "serializes an author properties" do
      author = FactoryGirl.create(:author)
      task.authors = [author]

      snapshot = Snapshot::AuthorTaskSerializer.new(task).snapshot
      properties = snapshot[:authors][0][:author]

      expect(find_property(properties, "first_name")).to eq(author.first_name)
      expect(find_property(properties, "last_name")).to eq(author.last_name)
      expect(find_property(properties, "middle_initial")).to eq(author.middle_initial)
      expect(find_property(properties, "position")).to eq(author.position)
      expect(find_property(properties, "email")).to eq(author.email)
      expect(find_property(properties, "department")).to eq(author.department)
      expect(find_property(properties, "title")).to eq(author.title)
      expect(find_property(properties, "affiliation")).to eq(author.affiliation)
      expect(find_property(properties, "secondary_affiliation")).to eq(author.secondary_affiliation)
      expect(find_property(properties, "ringgold_id")).to eq(author.ringgold_id)
      expect(find_property(properties, "secondary_ringgold_id")).to eq(author.secondary_ringgold_id)
    end

    it "serializes an authors nested questions" do
      author = FactoryGirl.create(:author)
      corresponding_answer = FactoryGirl.create(:nested_question_answer)
      corresponding_answer.nested_question_id = author.nested_questions.first.id
      corresponding_answer.owner_id = author.id
      corresponding_answer.owner_type = "Author"
      corresponding_answer.value = "t"
      allow_any_instance_of(Author).to receive(:nested_question_answers).and_return([corresponding_answer])
      task.authors = [author]

      snapshot = Snapshot::AuthorTaskSerializer.new(task).snapshot
      properties = snapshot[:authors][0][:author]

      expect(find_property(properties, "published_as_corresponding_author")[:answer]).to eq("t")
      expect(find_property(properties, "deceased")[:answer]).to be_nil
    end

    it "serializes authors according to position" do
      author1 = FactoryGirl.create(:author)
      author1.first_name = "First"
      author2 = FactoryGirl.create(:author)
      author2.first_name = "Second"
      author3 = FactoryGirl.create(:author)
      author3.first_name = "Third"
      task.authors = [author3, author1, author2]

      snapshot = Snapshot::AuthorTaskSerializer.new(task).snapshot
      properties1 = snapshot[:authors][0][:author]
      properties2 = snapshot[:authors][1][:author]
      properties3 = snapshot[:authors][2][:author]

      expect(find_property(properties1, "first_name")).to eq(author1.first_name)
      expect(find_property(properties2, "first_name")).to eq(author2.first_name)
      expect(find_property(properties3, "first_name")).to eq(author3.first_name)
    end
  end
end
