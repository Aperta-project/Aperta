class AffiliationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

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
    current_user.id == params[:user_id].to_i ||
      requires_user_can(:manage_users, Journal)

    render json: Affiliation.where(user_id: params[:user_id])
  end

  def show
    current_user == affiliation.user ||
      requires_user_can(:manage_users, Journal)

    render json: affiliation
  end

  def update
    (current_user == affiliation.user &&
     current_user.id == affiliation_params[:user_id].to_i) ||
      requires_user_can(:manage_users, Journal)

    affiliation.update_attributes! affiliation_params
    respond_with affiliation
  end

  def create
    (current_user == user &&
     current_user.id == affiliation_params[:user_id].to_i) ||
      requires_user_can(:manage_users, Journal)

    new_affiliation = user.affiliations.create!(affiliation_params)
    render json: new_affiliation
  end

  def destroy
    current_user == affiliation.user ||
      requires_user_can(:manage_users, Journal)

    if affiliation.try(:destroy)
      render json: true
    else
      render status: 400
    end
  end

  private

  def user
    @user ||= begin
      User.find(params[:user_id] || affiliation_params[:user_id])
    end
  end

  def affiliation
    @affiliation ||= begin
      Affiliation.find(params[:id])
    end
  end

  def affiliation_params
    params.require(:affiliation).permit(:name, :start_date, :end_date, :email, :department, :title, :country, :ringgold_id, :user_id)
  end
end
