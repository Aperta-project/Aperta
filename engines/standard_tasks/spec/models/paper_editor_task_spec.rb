require 'spec_helper'

describe StandardTasks::PaperEditorTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }
  describe "#paper_role" do
    let(:user) { FactoryGirl.build(:user) }
    let!(:paper_role) { create(:paper_role, :editor, paper: paper, user: user) }
    let!(:phase) { paper.phases.first }
    let(:task) { StandardTasks::PaperEditorTask.create!(phase: phase, title: "Assign Editor", role: 'admin') }

    context "when the role is not present" do
      it "initializes a new editor role" do
        role = task.paper_role
        expect(role.paper).to eq paper
        expect(role.role).to eq('editor')
      end
    end

    context "when the role is present" do
      it "returns the role" do
        # Setting up associations with several has_throughs is difficulte to verify
        # directly.
        # After reloading the task can get its paper_role directly,
        # but if the record hasn't been persisted we'd need to use
        # task.phase.paper.paper_roles.where(editor: true)
        expect(StandardTasks::PaperEditorTask.create!(phase: phase, title: "Assign Editor", role: 'admin').reload.paper_role).to eq paper_role
      end
    end
  end

  describe "#editor_id" do
    let(:task) { StandardTasks::PaperEditorTask.create! phase: paper.phases.first, title: "Assign Editor", role: 'admin' }
    let(:editor) { FactoryGirl.create(:user) }

    before do
      create(:paper_role, :editor, paper: paper, user: editor)
    end

    it "returns the current editor's id" do
      expect(task.editor_id).to eq editor.id
    end
  end

  describe "#editor_id=" do
    let(:task) { StandardTasks::PaperEditorTask.create! phase: paper.phases.first, title: "Assign Editor", role: 'admin'}
    let(:current_editor) { FactoryGirl.create(:user) }
    let(:future_editor) { FactoryGirl.create(:user) }

    let!(:original_paper_role) { create(:paper_role, :editor, paper: paper, user: current_editor) }

    it "sets the editor id by deleting and adding paper roles (necessary for event stream)" do
      task.editor_id = future_editor.id
      expect(task.reload.editor_id).to eq(future_editor.id)
      expect{ original_paper_role.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
