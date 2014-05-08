class AffiliationsController < ApplicationController

  def index
    parser = InstitutionHashParser.new(institution_hash)
    parser.parse_names!
    render json: parser.names, root: :institutions
  end

  def create
    affiliation = current_user.affiliations.create!(affiliation_params)
    render json: affiliation
  end

  private

  def institution_hash
    YAML.load File.read Rails.root.join("config/institutions.yml")
  end

  def affiliation_params
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email)
  end
end
