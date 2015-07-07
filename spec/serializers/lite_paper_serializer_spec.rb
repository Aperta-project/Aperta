require "rails_helper"

describe LitePaperSerializer, focus: true do
  describe "all_roles" do
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

    let(:roles) do
      serialized_paper = JSON.parse(
        LitePaperSerializer.new(paper).to_json,
        symbolize_names: true)
      serialized_paper[:lite_paper][:all_roles]
    end

    it "lists the author" do
      authors = roles.find { |r| r[:name] == "Collaborator" }[:users]
      expect(authors[0][:id]).to be(creator.id)
    end

    it "lists the reviewer" do
      reviewers = roles.find { |r| r[:name] == "Reviewer" }[:users]
      expect(reviewers[0][:id]).to be(reviewer.id)
    end

    it "lists the editor" do
      editors = roles.find { |r| r[:name] == "Editor" }[:users]
      expect(editors[0][:id]).to be(editor.id)
    end
  end
end
