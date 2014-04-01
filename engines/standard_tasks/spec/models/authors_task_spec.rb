require 'spec_helper'

describe StandardTasks::AuthorsTask do
  describe "defaults" do
    subject(:task) { StandardTasks::AuthorsTask.new }
    specify { expect(task.title).to eq 'Add Authors' }
    specify { expect(task.role).to eq 'author' }
  end

  describe "#authors" do
    let :task do
      paper = Paper.create! title: "Foo bar", short_title: "Foo", journal: Journal.create!
      task = StandardTasks::AuthorsTask.create! completed: true,
        phase: paper.task_manager.phases.first

      allow(paper).to receive(:authors).and_return [
        { first_name: 'Neils', last_name: 'Bohr', email: 'neils@example.com', affiliation: 'Home' },
        { first_name: 'Albert', last_name: 'Einstein', email: 'emc2@example.com', affiliation: 'School' }
      ]
      allow(task).to receive(:paper).and_return paper
      task
    end

    it "returns a list of authors" do
      expect(task.authors).to eq [
        { first_name: 'Neils', last_name: 'Bohr', email: 'neils@example.com', affiliation: 'Home' },
        { first_name: 'Albert', last_name: 'Einstein', email: 'emc2@example.com', affiliation: 'School' }
      ]
    end
  end
end
