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

describe Paper::DecisionMade::UnassignReviewers do
  include EventStreamMatchers

  context "rescinding invites" do
    let!(:journal) do
      FactoryGirl.create :journal,
        :with_reviewer_role
    end
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:reviewer_task) do
      FactoryGirl.create(:paper_reviewer_task, paper: paper)
    end
    let!(:invitation) do
      FactoryGirl.create(:invitation, :invited, task: reviewer_task)
    end

    it "rescinds the invitations" do
      expect(reviewer_task.invitations.where(state: "invited").count).to eq(1)
      described_class.call("tahi:paper:withdrawn", record: paper)
      reviewer_task.reload
      expect(reviewer_task.invitations.where(state: "invited").count).to eq(0)
    end
  end

  context "unassigning reviewers from the paper" do
    let!(:journal) do
      FactoryGirl.create :journal,
        :with_reviewer_role,
        :with_reviewer_report_owner_role,
        :with_task_participant_role
    end
    let(:paper) { FactoryGirl.create :paper, journal: journal }
    let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }
    let(:reviewer_report_task) do
      FactoryGirl.create :reviewer_report_task, paper: paper
    end
    let!(:reviewer) { create :user }

    before do
      assign_reviewer_role paper, reviewer
      assign_task_participant_role reviewer_report_task, reviewer
    end

    it "unassigns reviewers from the paper" do
      expect(paper.reviewers.count).to eq(1)
      described_class.call("tahi:paper:withdrawn", record: paper)
      expect(paper.reviewers.count).to eq(0)
    end

    it "unassigns reviewers as participants from their reviewer report tasks" do
      described_class.call("tahi:paper:withdrawn", record: paper)
      assignments = Assignment.where(user: reviewer,
                                     assigned_to: reviewer_report_task,
                                     role: journal.task_participant_role)
      expect(assignments).to eq([])
    end
  end
end
