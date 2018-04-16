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

describe SerializeIdsWithPolymorphism do
  describe ".call" do
    let(:task) { [double(type: task_type, class: double(name: task_type), id: "234")] }
    let(:result) { SerializeIdsWithPolymorphism.call task }

    context "when there is no prefix" do
      let(:task_type) { "UploadManuscriptTask" }

      it "returns the task name" do
        expect(result).to eq [{ id: task[0].id, type: task_type.underscore.dasherize }]
      end
    end

    context "when the prefix is a task bundle" do
      let(:task_type) { "TahiStandardTasks::FigureTask" }

      it "returns the last part of the task type" do
        expect(result).to eq([{ id: task[0].id, type: "figure-task" }])
      end
    end

    context "when the task is deeply namespaced" do
      let(:task_type) { "Tahi::StandardTasks::FigureTask" }

      it "returns the last part of the task type" do
        expect(result).to eq([{ id: task[0].id, type: "figure-task" }])
      end
    end

    context "when the task is really, deeply namespaced" do
      let(:task_type) { "Tahi::Standard::Tasks::FigureTask" }

      it "returns the last part of the task type" do
        expect(result).to eq([{ id: task[0].id, type: "figure-task" }])
      end
    end

    context "when the task type is not qualified" do
      let(:task_type) { "Funky::Crazy::blah" }

      it "raises if task type is not qualified" do
        expect { result }.to raise_error(RuntimeError, "The task type: 'Funky::Crazy::blah' is not qualified.")
      end
    end
  end
end
