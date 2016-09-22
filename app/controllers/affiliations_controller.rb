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
    require_current_user_or_user_can(:manage_users, Journal)
    render json: Affiliation.where(user_id: params[:user_id])
  end

  def show
    require_current_user_or_user_can(:manage_users, Journal)
    render json: affiliation
  end

  def update
    require_current_user_or_user_can(:manage_users, Journal)
    affiliation.update_attributes! affiliation_params
    respond_with affiliation
  end

  def create
    require_current_user_or_user_can(:manage_users, Journal)
    new_affiliation = user.affiliations.create!(affiliation_params)
    render json: new_affiliation
  end

  def destroy
    require_current_user_or_user_can(:manage_users, Journal)

    if affiliation.try(:destroy)
      render json: true
    else
      render status: 400
    end
  end

  private

  def require_current_user_or_user_can(action, object)
    current_user_accessing_their_own_record? ||
      requires_user_can(action, object)
  end

  def user
    User.find(params[:user_id] || affiliation_params[:user_id])
  end

  def current_user_accessing_their_own_record?
    return false if current_user_listing_affiliations
    return false if current_user_showing_affiliation
    return false if affiliation_user_matches_current_user

    true
  end

  def current_user_listing_affiliations
    params[:user_id] && current_user.id != params[:user_id]
  end

  def current_user_showing_affiliation
    params[:id] && current_user.id != affiliation.user_id
  end

  def affiliation_user_matches_current_user
    params[:affiliation].try(:user_id) &&
      current_user.id != affiliation_params[:user_id]
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
