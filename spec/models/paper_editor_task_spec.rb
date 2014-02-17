require 'spec_helper'

describe PaperEditorTask do
  describe "defaults" do
    subject(:task) { PaperEditorTask.new }
    specify { expect(task.title).to eq 'Assign Editor' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "#paper_role" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:phase) { paper.task_manager.phases.first }

    context "when the role is not present" do
      it "initializes a new editor role" do
        role = PaperEditorTask.new(phase: phase).paper_role
        expect(role.paper).to eq paper
        expect(role).to be_editor
      end
    end

    context "when the role is present" do
      it "returns the role" do
        role = PaperRole.create! paper: paper, editor: true
        expect(PaperEditorTask.new(phase: phase).paper_role).to eq role
      end
    end
  end

  describe "#editor_id" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:task) { PaperEditorTask.create! phase: paper.task_manager.phases.first }

    let :editor do
      User.create! username: 'editor',
        first_name: 'Ernie', last_name: 'Editor',
        password: 'password', password_confirmation: 'password',
        email: 'editor@example.org'
    end

    before do
      PaperRole.create! paper: paper, editor: true, user: editor
    end

    it "returns the current editor's id" do
      expect(task.editor_id).to eq editor.id
    end
  end

  describe "#editors" do
    let(:paper) { Paper.create! short_title: 'Role Tester', journal: Journal.create! }
    let(:task) { PaperEditorTask.create! phase: paper.task_manager.phases.first }

    it "returns list of editors for the journal" do
      editors = double(:editors)
      expect(User).to receive(:editors_for).with(paper.journal).and_return editors
      expect(task.editors).to eq editors
    end
  end
end
