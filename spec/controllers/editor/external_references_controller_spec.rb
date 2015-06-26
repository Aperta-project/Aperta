require 'rails_helper'

describe Editor::ExternalReferencesController do
  describe "GET /editor/crossref" do
    it "makes a request to Crossref with the given param" do
      expect(RestClient).to receive(:get).
        with("http://search.crossref.org/dois?q=hello_world&sort=score").
        and_return('{}')
      get :crossref, query: "hello_world"
    end
  end

  describe "GET /editor/doi" do
    it "makes a request to DOI with the given param" do
      expect(RestClient).to receive(:get).
        with("http://dx.doi.org/hello_world/1/3/4", accept: "application/citeproc+json").
        and_return('{}')
      get :doi, doi: "hello_world/1/3/4"
    end
  end
end
