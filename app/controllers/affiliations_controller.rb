class AffiliationsController < ApplicationController
  def index
    render json: Institution.instance.names, root: :institutions
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
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email)
  end
end
