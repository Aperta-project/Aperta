class AffiliationsController < ApplicationController
  before_action :authenticate_user!

  def index
    query = params.dig(:query)
    if not query
      institutions = []
    else
      institutions = Institutions.instance.matching_institutions(query)
    end
    render json: institutions, root: :institutions
  end

  def for_user
    require_current_user_or_user_can(:manage_users, Journal)
    render json: Affiliation.where(user_id: params[:user_id])
  end

  def show
    require_current_user_or_user_can(:manage_users, Journal)
    render json: affiliation
  end

  def create
    require_current_user_or_user_can(:manage_users, Journal)
    new_affiliation = user.affiliations.create!(affiliation_params)
    render json: new_affiliation
  end

  def destroy
    current_user == affiliation.user || requires_user_can(:manage_users, Journal)
    if affiliation.try(:destroy)
      render json: true
    else
      render status: 400
    end
  end

  private

  def require_current_user_or_user_can(action, object)
    current_user == user || requires_user_can(action, object)
  end

  def user
    User.find(params[:user_id] || affiliation_params[:user_id])
  end

  def affiliation
    Affiliation.find(params[:id])
  end

  def affiliation_params
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email, :department, :title, :country, :ringgold_id, :user_id)
  end
end
