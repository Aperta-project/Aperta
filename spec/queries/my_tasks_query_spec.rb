require 'spec_helper'

describe MyTasksQuery do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end

  subject(:my_tasks) { MyTasksQuery.new(admin) }

  let(:paper1) { Paper.create! short_title: 'Example', journal: Journal.new }
  let(:paper2) { Paper.create! short_title: 'Another Example', journal: Journal.new }
  let(:task1) { paper1.tasks.detect { |t| t.title == 'Assign Editor' } }
  let(:task2) { paper1.tasks.detect { |t| t.title == 'Tech Check' } }
  let(:task3) { paper2.tasks.detect { |t| t.title == 'Assign Editor' } }

  before do
    [task1, task2, task3].each do |task|
      task.update(assignee: admin)
    end
  end

  describe "#paper_profiles" do
    it "returns a summary of papers and their tasks" do
      expect(my_tasks.paper_profiles).to include({
        paper2 => [task3]
      })
      expect(my_tasks.paper_profiles).to include({
        paper1 => [task2, task1]
      })
    end
  end
end
