require 'rails_helper'

describe TaskType do
  class SampleTaskForTestingTaskType ; end

  after do
    TaskType.deregister(SampleTaskForTestingTaskType)
  end

  describe ".register" do
    it "will add to the list of task types" do
      TaskType.register(SampleTaskForTestingTaskType, "title", "old_role")
      expect(TaskType.types.keys).to include("SampleTaskForTestingTaskType")
    end
  end

  describe ".deregister" do
    before do
      TaskType.register(SampleTaskForTestingTaskType, "title", "old_role")
    end

    it "will remove the class from the list of registered task types" do
      TaskType.deregister(SampleTaskForTestingTaskType)
      expect(TaskType.types.keys).to_not include("SampleTaskForTestingTaskType")
    end
  end

  describe ".constantize!" do
    context "with a registered class" do
      before do
        TaskType.register(SampleTaskForTestingTaskType, "title", "old_role")
      end

      it "constantizes" do
        expect(TaskType.constantize!("SampleTaskForTestingTaskType"))
          .to eq(SampleTaskForTestingTaskType)
      end
    end

    context "without a registered class" do
      it "errors" do
        expect { TaskType.constantize!("NotASampleTask") }.to raise_error(RuntimeError, "NotASampleTask is not a registered TaskType")
      end
    end
  end

end
