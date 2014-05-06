require 'spec_helper'

describe InstitutionsController do
  it "returns a list of the institution names" do
    get :index
    expect(JSON.parse(response.body)['institutions']).to include('Harvard University')
  end
end
