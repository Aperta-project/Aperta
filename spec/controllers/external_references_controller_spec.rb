require 'rails_helper'

describe ExternalReferencesController do
  describe "GET /crossref" do
    it "makes a request to Crossref with the given param" do
      expect(RestClient).to receive(:get).with("http://search.crossref.org/dois?q=hello_world&sort=score").and_return('blah')
      get :crossref, query: "hello_world"
    end
  end

  describe "GET /doi" do
    it "makes a request to DOI with the given param" do
      expect(RestClient).to receive(:get).
        with("http://dx.doi.org/hello_world/1/3/4", accept: "application/citeproc+json").
        and_return('blah')
      get :doi, doi: "hello_world/1/3/4"
    end
  end
end
