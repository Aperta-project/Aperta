require 'spec_helper'

describe Api::PapersController do
  let!(:paper1) { FactoryGirl.create(:paper,
                                     short_title: "paper-2",
                                     title: "First paper",
                                     paper_type: 'front_matter',
                                     authors: [{ first_name: 'Ryan',
                                                 last_name: 'Wold',
                                                 affiliation: 'Personal',
                                                 email: 'user@example.com' }]) }

  describe "GET index" do
    let!(:paper2) { FactoryGirl.create(:paper,
                                       short_title: "paper-1",
                                       title: "Second paper") }

    it "user can get a list of papers" do
      get :index

      expect(JSON.parse(response.body)).to eq(
        {
          papers: [
            { id: paper1.id, title: "First paper",
              authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
              paper_type: 'front_matter' },
            { id: paper2.id, title: "Second paper", authors: [], paper_type: 'research' }
          ]
        }.with_indifferent_access
      )
    end
  end

  describe "GET show" do
    it "user can get a single paper" do
      get :show, { id: paper1.id }

      data = JSON.parse response.body
      expect(data['papers'].length).to eq 1
      expect(data).to eq(
        {
          papers: [
            { id: paper1.id, title: "First paper",
              authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
              paper_type: 'front_matter' }
          ]
        }.with_indifferent_access
      )
    end
  end
end
