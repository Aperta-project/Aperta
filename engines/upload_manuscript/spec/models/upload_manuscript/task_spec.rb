require 'spec_helper'

module UploadManuscript
  describe Task do
    describe "defaults" do
      subject(:task) { UploadManuscript::Task.new }

      specify { expect(task.title).to eq 'Upload Manuscript' }
      specify { expect(task.role).to eq 'author' }
    end
  end
end
