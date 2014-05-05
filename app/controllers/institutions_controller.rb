class InstitutionsController < ApplicationController

  def index
    parser = InstitutionHashParser.new institution_hash
    parser.parse_names!
    querier = InstitutionListQuerier.new(parser.names)
    results = querier.list
    if params[:query]
      results = querier.filter params[:query]
    end
    render json: results
  end

  private
  def institution_hash
    YAML.load File.read Rails.root.join("config/institutions.yml")
  end
end
