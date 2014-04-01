require 'spec_helper'

describe StandardTasks::UploadManuscriptTask do
  describe "defaults" do
    subject(:task) { StandardTasks::UploadManuscriptTask.new }
    specify { expect(task.title).to eq 'Upload Manuscript' }
    specify { expect(task.role).to eq 'author' }
  end
end

