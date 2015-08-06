require 'rails_helper'

describe CountriesController do
  it "returns a list of countries", vcr: {cassette_name: 'ned_countries', record: :none} do
    get :index
    names = res_body['countries']
    expect(names).to include('Peru')
  end
end
