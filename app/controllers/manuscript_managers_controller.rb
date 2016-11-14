class ManuscriptManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def show
    head :ok
  end

  private

  def paper
    Paper.find_by_id_or_short_doi!(params[:paper_lookup_id])
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end
end
