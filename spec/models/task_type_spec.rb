require 'spec_helper'

describe TaskType do

  describe ".register" do
    before do
      class SampleTask; end
    end

    it "will add to the list of task types" do
      TaskType.register(SampleTask, "title", "role")
      expect(TaskType.types.keys).to include("SampleTask")
    end
  end

  describe ".constantize!" do

    context "with a registered class" do
      before do
        class SampleTask; end
        TaskType.register(SampleTask, "title", "role")
      end

      it "constantizes" do
        expect(TaskType.constantize!("SampleTask")).to eq(SampleTask)
      end
    end

    context "without a registered class" do
      it "errors" do
        expect{ TaskType.constantize!("NotASampleTask") }.to raise_error
      end
    end
  end

end
