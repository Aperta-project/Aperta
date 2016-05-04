class AffiliationsController < ApplicationController
  before_action :authenticate_user!

  def index
    query = params.dig(:query)
    if not query
      institutions = []
    else
      institutions = Institutions.instance.matching_institutions(query)[0..10]
    end
    render json: institutions, root: :institutions
  end

  def create
    affiliation = current_user.affiliations.create!(affiliation_params)
    render json: affiliation
  end

  def destroy
    if affiliation.try(:destroy)
      render json: true
    else
      render status: 400
    end
  end

  private

  def affiliation
    current_user.affiliations.find(params[:id])
  end

  def affiliation_params
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email, :department, :title, :country, :ringgold_id)
  end
end
