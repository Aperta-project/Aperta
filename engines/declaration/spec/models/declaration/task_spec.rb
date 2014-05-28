require 'spec_helper'

module Declaration
  describe Task do
    describe "defaults" do
      subject(:task) { Declaration::Task.new }
      specify { expect(task.title).to eq 'Enter Declarations' }
      specify { expect(task.role).to eq 'author' }
    end

    describe "callbacks" do
      it "creates surveys" do
        expect{
          Declaration::Task.create(phase_id: 3)
        }.to change { Declaration::Survey.count }.by 3
      end
    end
  end
end
