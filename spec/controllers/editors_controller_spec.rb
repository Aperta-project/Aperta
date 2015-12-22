require 'rails_helper'

describe EditorsController do

  before { sign_in(user) }

  let(:user) { FactoryGirl.create(:user) }
  let(:paper) do
    paper = FactoryGirl.create(:paper)
    paper.paper_roles.create!(old_role: PaperRole::EDITOR, user: user)
    paper
  end

  describe "DELETE /papers/:id/editor" do
    it "removes the current paper editor" do
      delete(:destroy, {
        format: "json",
        paper_id: paper.id
      })
      expect(response.status).to eq(204)
      expect(paper.editor).to be_nil
    end
  end
end
