require 'rails_helper'

describe Author do
  context "validation" do
    it "will be valid with default factory data" do
      model = FactoryGirl.build(:author)
      expect(model).to be_valid
    end
  end

  describe "#task_completed?" do
    let(:authors_task) { AuthorsTask.new }

    it "is true when task is complete" do
      authors_task.completed = true
      expect(subject.class.new(authors_task: authors_task)).to be_task_completed
    end

    it "is false when task is incomplete" do
      authors_task.completed = false
      expect(subject.class.new(authors_task: authors_task)).to_not be_task_completed
    end

    it "is false when there is no task" do
      expect(subject.class.new(authors_task: nil)).to_not be_task_completed
    end
  end
end
