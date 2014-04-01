require 'spec_helper'

feature "Papers API", type: :api do
  include Rack::Test::Methods

  let :app do
    Rails.application
  end

  scenario "user can get a list of papers" do
    paper1 = FactoryGirl.create(:paper, short_title: "paper-1", title: "First paper")
    paper2 = FactoryGirl.create(:paper,
      short_title: "paper-2",
      title: "Second paper",
      authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
      paper_type: 'front_matter')

    get api_papers_path

    json = last_response.body
    data = JSON.parse(json)
    expect(data).to eq(
      {
        papers: [
          { id: paper1.id, title: "First paper", authors: [], paper_type: 'research' },
          { id: paper2.id, title: "Second paper",
            authors: [{ first_name: 'Ryan', last_name: 'Wold', affiliation: 'Personal', email: 'user@example.com' }],
            paper_type: 'front_matter'
          }
        ]
      }.with_indifferent_access
    )
  end
end