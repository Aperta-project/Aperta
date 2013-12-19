require 'spec_helper'

describe TechCheckTask do
  describe "defaults" do
    subject(:task) { TechCheckTask.new }
    specify { expect(task.title).to eq 'Tech Check' }
    specify { expect(task.role).to eq 'admin' }
  end
end
