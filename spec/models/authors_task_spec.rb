require 'spec_helper'

describe AuthorsTask do
  describe "defaults" do
    subject(:task) { AuthorsTask.new }
    specify { expect(task.title).to eq 'Add Authors' }
    specify { expect(task.role).to eq 'author' }
  end
end

