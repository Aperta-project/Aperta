require 'spec_helper'

describe PaperAdminTask do
  describe "defaults" do
    subject(:task) { PaperAdminTask.new }
    specify { expect(task.title).to eq 'Assign Admin' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "updating paper admin" do

    let(:task)  { PaperAdminTask.create(phase: phase, assignee: bob) }
    let(:paper) { Paper.create!(short_title: "something", journal: Journal.create!) }
    let(:phase) { paper.task_manager.phases.first }
    let(:sally) { User.create! email: 'sally@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'sallyplos' }
    let(:bob) { User.create! email: 'bob@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'bobplos' }

    context "when paper admin is changed" do
      before(:each) { task.paper.stub(:admin).and_return(bob) }
      it "will update paper and tasks" do
        task.should_receive(:update_paper_admin_and_tasks)
        task.admin_id = sally.id
        task.save
      end
    end

    context "when paper admin is not changed" do
      it "will not update paper or tasks" do
        task.should_not_receive(:update_paper_admin_and_tasks)
        task.save
      end
    end
  end
end
