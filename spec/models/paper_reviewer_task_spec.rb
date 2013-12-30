require 'spec_helper'

describe PaperReviewerTask do
  describe "defaults" do
    subject(:task) { PaperReviewerTask.new }
    specify { expect(task.title).to eq 'Assign Reviewer' }
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
        expect(PaperReviewerTask.new(phase: phase).paper_roles).to eq roles
      end
    end
  end

  describe "#paper_roles=" do
    let(:task) { PaperReviewerTask.new(phase: phase) }

    context "there are reviewer paper roles already" do
      it "creates reviewer paper roles only for new ids" do
        PaperRole.create! paper: paper, reviewer: true, user: albert
        task.paper_roles = ["", neil.id.to_s]
        expect(PaperRole.where(paper: paper, reviewer: true, user: neil)).not_to be_empty
      end

      it "deletes paper roles not present in the specified user_id" do
        PaperRole.create! paper: paper, reviewer: true, user: albert
        task.paper_roles = ["", neil.id.to_s]
        expect(PaperRole.where(paper: paper, reviewer: true, user: albert)).to be_empty
      end
    end
  end
end
