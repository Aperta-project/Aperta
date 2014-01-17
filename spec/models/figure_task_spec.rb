require 'spec_helper'

describe FigureTask do
  describe "defaults" do
    subject(:task) { FigureTask.new }
    specify { expect(task.title).to eq 'Upload Figures' }
    specify { expect(task.role).to eq 'author' }
  end
end
