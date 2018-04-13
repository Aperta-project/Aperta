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

describe TahiStandardTasks::TitleAndAbstractTask do
  describe "#Instance methods" do
    let!(:paper) do
      FactoryGirl.create :paper, :with_tasks
    end
    let!(:task) do
      FactoryGirl.create(:title_and_abstract_task, paper: paper)
    end

    describe "#paper_abstract" do
      context "is a string" do
        before do
          task.paper_abstract = "hiya"
          task.save!
        end
        it "sets abstract on paper" do
          expect(paper.abstract).to eq("hiya")
        end
      end

      context "is an empty string" do
        before do
          task.paper_abstract = " "
          task.save!
        end
        it "sets abstract on paper to nil" do
          expect(paper.abstract).to eq(nil)
        end
      end
    end

    describe "#paper_title" do
      context "is a string" do
        before do
          task.paper_title = "this is the title"
          task.save!
        end
        it "sets title on paper" do
          expect(paper.title).to eq("this is the title")
        end
      end
    end
  end

  describe "#Class Methods" do
    describe "#setup_new_revision" do
      let!(:paper) do
        FactoryGirl.create(
          :paper_with_phases,
          editable: false,
          phases_count: 3
        )
      end

      let(:phase) { paper.phases[1] }
      subject(:subject) { TahiStandardTasks::TitleAndAbstractTask }

      context "with an existing revise task" do
        let!(:task) do
          FactoryGirl.create(
            :title_and_abstract_task,
            completed: true,
            paper: paper
          )
        end

        it "uncompletes the task" do
          subject.setup_new_revision paper, phase
          expect(task.reload.completed).to be(false)
        end
      end

      context "with no existing revise task" do
        it "creates a new revise task" do
          expect(TaskFactory)
            .to receive(:create).with(
              subject,
              paper: paper,
              phase: phase
            )

          subject.setup_new_revision paper, phase
        end
      end
    end
  end
end
