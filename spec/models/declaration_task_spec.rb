require 'spec_helper'

describe DeclarationTask do
  describe "defaults" do
    subject(:task) { DeclarationTask.new }
    specify { expect(task.title).to eq 'Declarations' }
    specify { expect(task.role).to eq 'author' }
  end
end

