require 'rails_helper'

describe CountriesController do
  it "returns a list of countries", vcr: { cassette_name: 'ned_countries', record: :none } do
    get :index
    names = res_body['countries']
    expect(names).to include('Peru')
  end

  it "returns a sorted list of countries", vcr: { cassette_name: 'ned_countries', record: :none } do
    get :index
    names = res_body['countries']
    expect(names).to eq(names.sort_alphabetical)
  end

  it "does not sort unicode to the end", vcr: { cassette_name: 'ned_countries', record: :none } do
    get :index
    names = res_body['countries']
    expect(names).to eq(names.sort_alphabetical)
    expect(names[-1]).to eq('Zimbabwe')
  end
end
