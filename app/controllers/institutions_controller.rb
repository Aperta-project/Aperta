class InstitutionsController < ApplicationController

  def index
    parser = InstitutionHashParser.new institution_hash
    parser.parse_names!
    render json: parser.names
  end

  private
  def institution_hash
    YAML.load File.read Rails.root.join("config/institutions.yml")
  end
end
