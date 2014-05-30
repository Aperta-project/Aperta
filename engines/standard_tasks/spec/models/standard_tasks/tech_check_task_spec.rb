require 'spec_helper'

describe StandardTasks::TechCheckTask do
  describe "defaults" do
    subject(:task) { StandardTasks::TechCheckTask.new }
    specify { expect(task.title).to eq 'Tech Check' }
    specify { expect(task.role).to eq 'admin' }
  end
end
