require 'spec_helper'

describe AuthorGroupsController do
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
  end

  describe "POST #create" do
    let(:paper) { FactoryGirl.create(:paper) }
    let(:do_request) do
      post :create, author_group: { paper_id: paper.id }
    end
    it "creates a new author group" do
      expect { do_request }.to change { AuthorGroup.count }.by 1
    end

    it "associates the author group to the paper" do
      do_request
      expect(AuthorGroup.last.paper).to eq paper
    end

    it "returns an author group with a correctly incremented name" do
      do_request
      author_group = JSON.parse(response.body)["author_group"]
      expect(author_group['name']).to eq "First Author"
    end
  end

  describe "DELETE #destroy" do
    let(:do_request) do
      delete :destroy, id: author_group.id
    end
    let!(:author_group) { FactoryGirl.create :author_group, authors: [ author ]}
    let(:author) { FactoryGirl.create :author }

    it "destroys the author_group" do
      expect {
        do_request
      }.to change { AuthorGroup.count }.by -1
    end

    it "destroys the associated author" do
      expect {
        do_request
      }.to change { Author.count }.by -1
    end
  end
end
