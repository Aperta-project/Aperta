require 'spec_helper'

describe PaperReviewerTask do
  describe "defaults" do
    subject(:task) { PaperReviewerTask.new }
    specify { expect(task.title).to eq 'Assign Reviewers' }
    specify { expect(task.role).to eq 'editor' }
  end

  let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
  let(:phase) { paper.task_manager.phases.first }

  let(:albert) do
    User.create! username: 'albert',
      first_name: 'albert',
      last_name: 'einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'universität zürich',
      admin: true
  end

  let(:neil) do
    User.create! username: 'neil',
      first_name: 'Neil',
      last_name: 'Bohrs',
      email: 'neil@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'universität zürich'
  end

  describe "#paper_roles" do
    context "when no roles exist" do
      specify { expect(PaperReviewerTask.new(phase: phase).paper_roles).to be_empty }
    end

    context "when roles exist" do
      let(:bob) { User.create! username: 'bob', email: 'bob@example.com', password: 'password', password_confirmation: 'password' }
      let(:ralph) { User.create! username: 'ralph', email: 'ralph@example.com', password: 'password', password_confirmation: 'password' }
      it "returns the roles" do
        roles = [PaperRole.create!(paper: paper, reviewer: true, user: bob).user_id,
                 PaperRole.create!(paper: paper, reviewer: true, user: ralph).user_id]
        expect(PaperReviewerTask.new(phase: phase).paper_roles).to match_array roles
      end
    end
  end

  describe "#paper_roles=" do
    let(:task) { PaperReviewerTask.create!(phase: phase) }

    it "creates reviewer paper roles only for new ids" do
      PaperRole.create! paper: paper, reviewer: true, user: albert
      task.paper_roles = ["", neil.id.to_s]
      expect(PaperRole.where(paper: paper, reviewer: true, user: neil)).not_to be_empty
    end

    it "creates reviewer report tasks only for new ids" do
      task.paper_roles = ["", neil.id.to_s]
      phase = paper.task_manager.phases.where(name: 'Get Reviews').first
      expect(ReviewerReportTask.where(assignee: neil, phase: phase)).to be_present
    end

    it "deletes reviewer report tasks of the ids not specified" do
      phase = paper.task_manager.phases.where(name: 'Get Reviews').first
      PaperRole.create! paper: paper, reviewer: true, user: albert
      ReviewerReportTask.create! assignee: albert, phase: phase
      task.paper_roles = ["", neil.id.to_s]
      expect(ReviewerReportTask.where(assignee: albert, phase: phase)).to be_empty
    end

    it "deletes paper roles not present in the specified user_id" do
      PaperRole.create! paper: paper, reviewer: true, user: albert
      task.paper_roles = ["", neil.id.to_s]
      expect(PaperRole.where(paper: paper, reviewer: true, user: albert)).to be_empty
    end
  end

  describe "#reviewer_ids" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:task) { PaperReviewerTask.create! phase: paper.task_manager.phases.first }

    let :reviewer1 do
      User.create! username: 'revi',
        first_name: 'Rose', last_name: 'Reviewer',
        password: 'password', password_confirmation: 'password',
        email: 'rose@example.org'
    end

    let :reviewer2 do
      User.create! username: 'ewer',
        first_name: 'Robbie', last_name: 'Reviewer',
        password: 'password', password_confirmation: 'password',
        email: 'robbie@example.org'
    end

    before do
      PaperRole.create! paper: paper, reviewer: true, user: reviewer1
      PaperRole.create! paper: paper, reviewer: true, user: reviewer2
    end

    it "returns the current reviewer IDs" do
      expect(task.reviewer_ids).to match_array [reviewer1.id, reviewer2.id]
    end
  end
end
