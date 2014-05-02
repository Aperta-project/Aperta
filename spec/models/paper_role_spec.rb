require 'spec_helper'

describe PaperRole do
  describe "scopes" do
    describe "reviewers_for" do
      let(:user) { FactoryGirl.build(:user) }
      let(:paper) { Paper.create! short_title: "Hello", journal: Journal.create! }
      it "returns reviewers for a given paper" do
        reviewer_paper_role = PaperRole.create!(reviewer: true, paper: paper, user: user)
        other_paper_role = PaperRole.create!(paper: paper, user: user)
        
        expect(PaperRole.reviewers_for(paper)).to_not include other_paper_role
        expect(PaperRole.reviewers_for(paper)).to include reviewer_paper_role
      end
    end
  end

  describe "callbacks" do
    let(:paper) { Paper.create! short_title: "Hello", journal: Journal.create! }
    let(:default_task_attrs) { { title: 'A title', role: 'editor', phase: paper.task_manager.phases.first } }

    describe "after_save" do
      let(:bob) { User.create! email: 'bob@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'bobplos' }

      let(:steve) { User.create! email: 'steve@plos.org',
        password: 'abcd1234',
        password_confirmation: 'abcd1234',
        username: 'steveplos' }

      context "when the assignee is not changing" do
        it "does not modify other tasks" do
          paper_role = PaperRole.create! user: bob, paper: paper, editor: true
          task = Task.create! default_task_attrs
          paper_role.update! reviewer: true
          expect(task.reload.assignee).to be_nil
        end
      end

      context "when the role is not editor" do
        it "does not modify other tasks" do
          task = Task.create! default_task_attrs
          paper_role = PaperRole.create! user: bob, paper: paper, editor: false
          expect(task.reload.assignee).to be_nil
        end
      end

      context "when there are editor tasks with no assignee" do
        it "assigns the task to the PaperEditorTask assignee" do
          task = Task.create! default_task_attrs
          paper_role = PaperRole.create! user: bob, paper: paper, editor: true
          expect(task.reload.assignee).to eq(bob)
        end
      end

      context "when there are editor tasks with the old assignee" do
        it "assigns the task to the PaperEditorTask assignee" do
          task = Task.create! default_task_attrs.merge(assignee: bob)
          paper_role = PaperRole.create! user: steve, paper: paper, editor: true
          expect(task.reload.assignee).to eq(steve)
        end
      end

      context "when there are editor tasks assigned to another editor" do
        let(:dave) { User.create! email: 'dave@plos.org',
          password: 'abcd1234',
          password_confirmation: 'abcd1234',
          username: 'daveplos' }

        it "does not assign the task to the PaperEditorTask assignee" do
          paper_role = PaperRole.create! user: bob, paper: paper, editor: true
          task = Task.create! default_task_attrs.merge(assignee: dave)
          paper_role.update! user: steve
          expect(task.reload.assignee).to eq(dave)
        end
      end

      context "when there are completed tasks" do
        it "does not assign the task to the PaperEditorTask assignee" do
          task = Task.create! default_task_attrs.merge(assignee: bob, completed: true)
          paper_role = PaperRole.create! user: steve, paper: paper, editor: true
          expect(task.reload.assignee).to eq(bob)
        end
      end
    end
  end

end
