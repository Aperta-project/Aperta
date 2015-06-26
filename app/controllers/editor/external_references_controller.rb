module Editor
  class ExternalReferencesController < ApplicationController
    def crossref
      response = RestClient.get "http://search.crossref.org/dois?q=#{params[:query]}&sort=score"
      render json: response
    end

    def doi
      response = RestClient.get "http://dx.doi.org/#{params[:doi]}", accept: 'application/citeproc+json'
      render json: response
    end
  end
end
