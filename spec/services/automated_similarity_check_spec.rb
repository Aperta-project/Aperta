require 'rails_helper'

describe AutomatedSimilarityCheck do
  describe "should_run?" do
    context "the paper has a SimilarityCheckTask" do
      context "the task is configured to never run" do

      end

      context "the task is configured to run on the submission after the first revision (major or minor)" do

      end

      context "the task is configured to run on the submission after first minor revision" do

      end

      context "the task is configured to run on the submission after first major revision" do

      end
    end

    context "no similarity check task for the paper" do
      it "returns false"
    end
  end
end
