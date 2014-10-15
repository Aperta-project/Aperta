require 'spec_helper'

describe PlosAuthors::PlosAuthorsTask do
  describe "defaults" do
    subject(:task) { PlosAuthors::PlosAuthorsTask.new }
    specify { expect(task.title).to eq 'Add Authors' }
    specify { expect(task.role).to eq 'author' }
  end
end

