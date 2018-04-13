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

describe AutomatedSimilarityCheck do
  let!(:task_template) { FactoryGirl.create(:task_template) }
  subject(:result) { described_class.new(task, paper).run }

  describe "should_run?" do
    context "a SimilarityCheckTask has been added to the workflow after the paper is created" do
      let!(:paper) do
        FactoryGirl.create(
          :paper,
          :with_creator,
          :with_versions
        )
      end
      let!(:task) do
        FactoryGirl.create(
          :similarity_check_task,
          paper: paper
          # Note that tasks added to the workflow directly won't be associated to a TaskTemplate
        )
      end

      before do
        allow(paper).to receive_message_chain(:aasm, :from_state).and_return(:unsubmitted)
      end

      it "returns nil" do
        expect(result).to be_nil
      end
    end

    context "a paper with a SimilarityCheckTask has been initially submitted" do
      let!(:paper) do
        FactoryGirl.create(
          :paper,
          :with_creator,
          :with_versions
        )
      end
      let!(:task) do
        FactoryGirl.create(
          :similarity_check_task,
          paper: paper,
          task_template: task_template
        )
      end

      before do
        allow(paper).to receive_message_chain(:aasm, :from_state).and_return(:unsubmitted)
      end

      context "the task is configured to never run" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                             owner: task_template)
        end
        it "doesn't create a SimilarityCheck record" do
          expect(result).to be_nil
        end
      end

      context "the task is configured to run on the submission after the first submission" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                             :at_first_full_submission, owner: task_template)
        end

        it "creates a SimilarityCheck record on first submission" do
          expect(result.class).to eq(SimilarityCheck)
        end

        it "does not create a similarity check if one already exists" do
          FactoryGirl.create(:similarity_check, versioned_text: paper.latest_version)
          expect(result).to be_nil
        end
      end

      context "the task is configured to run on the submission after a major revise decision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                             :after_major_revise_decision, owner: task_template)
        end

        it "does not create a SimilarityCheck record" do
          expect(result).to be_nil
        end
      end
    end

    context "a paper with a SimilarityCheckTask is in minor revision" do
      let!(:paper) do
        FactoryGirl.create(
          :paper,
          :with_creator,
          :with_versions,
          :first_minor_revision
        )
      end
      let!(:task) do
        FactoryGirl.create(
          :similarity_check_task,
          paper: paper,
          task_template: task_template
        )
      end

      before do
        allow(paper).to receive_message_chain('tasks.find_by').and_return task
        allow(paper).to receive_message_chain(:aasm, :from_state).and_return(:in_revision)
      end

      context "the task is configured to run on the submission after any first revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_any_first_revise_decision, owner: task_template)
        end

        it "creates a SimilarityCheck record" do
          expect(result.class).to eq(SimilarityCheck)
        end

        it "does not create a similarity check if one already exists" do
          FactoryGirl.create(:similarity_check, versioned_text: paper.latest_version)
          expect(result).to be_nil
        end
      end

      context "the task is configured to run on the first submission after a minor revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_minor_revise_decision, owner: task_template)
        end

        it "creates a SimilarityCheck record" do
          expect(result.class).to eq(SimilarityCheck)
        end

        it "does not create a similarity check if one already exists" do
          FactoryGirl.create(:similarity_check, versioned_text: paper.latest_version)
          expect(result).to be_nil
        end
      end

      context "a paper has been through more than one revision" do
        before do
          # adds a major revision onto the previous minor revision
          paper.decisions.create!(verdict: "minor_revision", major_version: 0, minor_version: 2)
        end
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                             :after_minor_revise_decision, owner: task_template)
        end

        it "creates a SimilarityCheck record" do
          expect(result.class).to eq(SimilarityCheck)
        end
      end

      context "the task is configured to run on the first submission after a major revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_major_revise_decision, owner: task_template)
        end

        it "does not create a SimilarityCheck record" do
          expect(result).to be_nil
        end
      end
    end

    context "a paper with a SimilarityCheckTask is in major revision" do
      let!(:paper) do
        FactoryGirl.create(
          :paper,
          :with_creator,
          :with_versions,
          :first_major_revision
        )
      end
      let!(:task) do
        FactoryGirl.create(
          :similarity_check_task,
          paper: paper,
          task_template: task_template
        )
      end

      before do
        allow(paper).to receive_message_chain('tasks.find_by').and_return task
        allow(paper).to receive_message_chain(:aasm, :from_state).and_return(:in_revision)
      end

      context "the task is configured to run on the submission after any first revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_any_first_revise_decision, owner: task_template)
        end

        it "creates a SimilarityCheck record" do
          expect(result.class).to eq(SimilarityCheck)
        end

        it "does not create a similarity check if one already exists" do
          FactoryGirl.create(:similarity_check, versioned_text: paper.latest_version)
          expect(result).to be_nil
        end
      end

      context "the task is configured to run on the first submission after a minor revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_minor_revise_decision, owner: task_template)
        end

        it "does not create a SimilarityCheck record" do
          expect(result).to be_nil
        end
      end

      context "the task is configured to run on the submission after a major revision" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_major_revise_decision, owner: task_template)
        end

        it "creates a SimilarityCheck record" do
          expect(result.class).to eq(SimilarityCheck)
        end

        it "does not create a similarity check if one already exists" do
          FactoryGirl.create(:similarity_check, versioned_text: paper.latest_version)
          expect(result).to be_nil
        end
      end

      context "regarding similarity check automation" do
        let!(:setting) do
          FactoryGirl.create(:ithenticate_automation_setting,
                                            :after_major_revise_decision, owner: task_template)
        end

        context "the paper has had a manually generated report" do
          before do
            versioned_text = FactoryGirl.create(:versioned_text, paper: paper)
            FactoryGirl.create(:similarity_check, versioned_text: versioned_text, automatic: false)
            paper.versioned_texts << versioned_text
          end

          it "does not create a SimilarityCheck record" do
            expect(result).to be_nil
          end
        end

        context "the paper is automatically checked" do
          before do
            versioned_text = FactoryGirl.create(:versioned_text, paper: paper)
            FactoryGirl.create(:similarity_check, versioned_text: versioned_text, automatic: true)
            paper.versioned_texts << versioned_text
          end

          it "it creates a SimilarityCheck record" do
            expect(result.class).to eq(SimilarityCheck)
          end
        end
      end
    end
  end
end
