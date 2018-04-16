# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe TaskType do
  class SampleTaskForTestingTaskType; end

  after do
    TaskType.deregister(SampleTaskForTestingTaskType)
  end

  describe ".register" do
    it "will add to the list of task types" do
      TaskType.register(SampleTaskForTestingTaskType, "title")
      expect(TaskType.types.keys).to include("SampleTaskForTestingTaskType")
    end
  end

  describe ".deregister" do
    before do
      TaskType.register(SampleTaskForTestingTaskType, "title")
    end

    it "will remove the class from the list of registered task types" do
      TaskType.deregister(SampleTaskForTestingTaskType)
      expect(TaskType.types.keys).to_not include("SampleTaskForTestingTaskType")
    end
  end

  describe ".constantize!" do
    context "with a registered class" do
      before do
        TaskType.register(SampleTaskForTestingTaskType, "title")
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
