require 'spec_helper'

describe PaperEditorTask do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }
  describe "defaults" do
    subject(:task) { PaperEditorTask.new }
    specify { expect(task.title).to eq 'Assign Editor' }
    specify { expect(task.role).to eq 'admin' }
  end

  describe "#paper_role" do
    let(:user) { FactoryGirl.build(:user) }
    let!(:paper_role) { PaperRole.create! paper: paper, editor: true, user: user }
    let!(:phase) { paper.phases.first }
    let(:task) { PaperEditorTask.create!(phase: phase) }

    context "when the role is not present" do
      it "initializes a new editor role" do
        role = task.paper_role
        expect(role.paper).to eq paper
        expect(role).to be_editor
      end
    end

    context "when the role is present" do
      it "returns the role" do
        # Setting up associations with several has_throughs is difficulte to verify
        # directly.
        # After reloading the task can get its paper_role directly,
        # but if the record hasn't been persisted we'd need to use
        # task.phase.paper.paper_roles.where(editor: true)
        expect(PaperEditorTask.create!(phase: phase).reload.paper_role).to eq paper_role
      end
    end
  end

  describe "#editor_id" do
    let(:task) { PaperEditorTask.create! phase: paper.phases.first }
    let(:editor) { FactoryGirl.create(:user) }

    before do
      PaperRole.create! paper: paper, editor: true, user: editor
    end

    it "returns the current editor's id" do
      expect(task.editor_id).to eq editor.id
    end
  end
end
