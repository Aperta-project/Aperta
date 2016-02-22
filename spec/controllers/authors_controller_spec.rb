require 'rails_helper'

describe AuthorsController do
  let(:user) { paper.creator }
  let(:paper) { FactoryGirl.create(:paper, :with_creator, :with_integration_journal) }
  let(:task) { FactoryGirl.create(:authors_task, paper: paper) }

  before do
    sign_in user
  end

  describe "POST #create" do
    let(:do_request) do
      post :create, format: :json, author: {
        first_name: "enrico",
        last_name: "fermi",
        paper_id: paper.id,
        authors_task_id: task.id,
        position: 1
      }
    end

    it "creates a new author" do
      expect { do_request }.to change { Author.count }.by 1
    end
  end

  describe "DELETE #destroy" do
    let(:do_request) do
      delete :destroy, format: :json, id: author.id
    end

    let!(:author) { FactoryGirl.create(:author, paper: paper, authors_task_id: task.id) }

    it "destroys the associated author" do
      expect {
        do_request
      }.to change { Author.count }.by -1
    end
  end

  describe "PUT #update" do
    let(:do_request) do
      put :update, format: :json, id: author.id, author: { last_name: "Blabby", author_task_id: task.id }
    end

    let!(:author) { FactoryGirl.create(:author, paper: paper, authors_task_id: task.id) }

    it "updates the author" do
      do_request
      expect(author.reload.last_name).to eq "Blabby"
    end
  end
end
