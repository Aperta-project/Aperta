require "rails_helper"

describe PaperTrackerSerializer do
  describe "related_users" do
    let(:creator) { FactoryGirl.create :user }
    let(:paper) { FactoryGirl.create :paper, creator: creator }

    let(:editor) { FactoryGirl.create :user }
    let!(:editor_role) do
      FactoryGirl.create :paper_role, :editor,
                         paper: paper,
                         user: editor
    end

    let(:reviewer) { FactoryGirl.create :user }
    let!(:reviewer_role) do
      FactoryGirl.create :paper_role, :reviewer,
                         paper: paper,
                         user: reviewer
    end

    let(:old_roles) do
      serialized_paper = JSON.parse(
        PaperTrackerSerializer.new(paper).to_json,
        symbolize_names: true)
      serialized_paper[:paper_tracker][:related_users]
    end

    it "lists the author" do
      authors = old_roles.find { |r| r[:name] == "Collaborator" }[:users]
      expect(authors[0][:id]).to be(creator.id)
    end

    it "lists the reviewer" do
      reviewers = old_roles.find { |r| r[:name] == "Reviewer" }[:users]
      expect(reviewers[0][:id]).to be(reviewer.id)
    end

    it "lists the editor" do
      editors = old_roles.find { |r| r[:name] == "Editor" }[:users]
      expect(editors[0][:id]).to be(editor.id)
    end
  end
end
