require 'spec_helper'

describe StandardTasks::DeclarationTask do
  describe "defaults" do
    subject(:task) { StandardTasks::DeclarationTask.new }
    specify { expect(task.title).to eq 'Enter Declarations' }
    specify { expect(task.role).to eq 'author' }
  end
end

