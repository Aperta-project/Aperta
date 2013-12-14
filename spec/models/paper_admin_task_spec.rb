require 'spec_helper'

describe PaperAdminTask do
  describe "callbacks" do
    describe "after_update" do
      let(:bob) { User.create! email: 'bob@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'bobplos' }

      let(:steve) { User.create! email: 'steve@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'steveplos' }

      context "when there are admin tasks with no assignee" do
        let!(:task) { Task.create! role: 'admin' }

        it "assigns the task to the PaperAdminTask assignee" do
          PaperAdminTask.create! assignee: bob
          expect(task.reload.assignee).to eq(bob)
        end
      end

      context "when there are admin tasks with the old assignee" do
        let!(:task) { Task.create!(role: 'admin', assignee: bob) }

        it "assigns the task to the PaperAdminTask assignee" do
          PaperAdminTask.create! assignee: steve
          expect(task.reload.assignee).to eq(steve)
        end
      end

      context "when there are admin tasks assigned to another admin" do
        let(:dave) { User.create! email: 'dave@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'daveplos' }

        let!(:paper_admin_task) { PaperAdminTask.create! assignee: bob }
        let!(:task) { Task.create!(role: 'admin', assignee: dave) }

        it "does not assign the task to the PaperAdminTask assignee" do
          task.assignee = dave
          task.save!
          paper_admin_task.update! assignee: steve
          expect(task.reload.assignee).to_not eq(steve)
          expect(task.reload.assignee).to_not eq(dave)
        end
      end

      context "when there are completed tasks" do
        it "does not assign the task to the PaperAdminTask assignee"
      end
    end
  end
  describe "initialization" do
    describe "title" do
      it "initializes title to 'Paper Shepherd'" do
        expect(PaperAdminTask.new.title).to eq 'Paper Shepherd'
      end

      context "when a title is provided" do
        it "uses the specified title" do
          expect(PaperAdminTask.new(title: 'foo').title).to eq 'foo'
        end
      end
    end
  end
end
