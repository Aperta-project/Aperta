require 'spec_helper'

describe UploadManuscriptTask do
  describe "defaults" do
    subject(:task) { UploadManuscriptTask.new }
    specify { expect(task.title).to eq 'Upload Manuscript' }
    specify { expect(task.role).to eq 'author' }
  end
end

