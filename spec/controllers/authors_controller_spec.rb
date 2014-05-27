require 'spec_helper'

describe AuthorsController do
  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
  end

  describe "POST #create" do
    let(:do_request) do
      post :create, author: {
        first_name: "enrico",
        last_name: "fermi",
        email: "ricky@fermi.org",
        affiliation: "Harvey Mudd",
        paper_id: paper.id
      }
    end
    let(:paper) { FactoryGirl.create :paper }
    let(:author) { Author.last }

    it "creates a new author" do
      expect { do_request }.to change { Author.count }.by 1
    end

    it "creates the right author" do
      do_request
      expect(author.affiliation).to eq 'Harvey Mudd'
    end

    it "associates the author to the paper" do
      do_request
      expect(author.paper).to eq paper
    end
  end

  describe "PUT #update" do
    let(:do_request) do
      put :update, id: author.id, author: {
                                            secondary_affiliation: "Brisbon Uni",
                                            paper_id: paper.id
                                          }
    end
    let(:paper) { FactoryGirl.create :paper, authors: [ author ]}
    let(:author) { FactoryGirl.create :author }

    it "updates the author" do
      first_name = author.first_name
      do_request
      expect(author.reload.secondary_affiliation).to eq "Brisbon Uni"
      expect(author.first_name).to eq first_name
    end

  end
end
