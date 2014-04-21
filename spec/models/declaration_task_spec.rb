require 'spec_helper'

describe DeclarationTask do
  describe "defaults" do
    subject(:task) { DeclarationTask.new }
    specify { expect(task.title).to eq 'Enter Declarations' }
    specify { expect(task.role).to eq 'author' }
  end

  describe "callbacks" do
    it "creates surveys" do
      expect{
        DeclarationTask.create(phase_id: 3)
      }.to change { Survey.count }.by 3
    end
  end
end

