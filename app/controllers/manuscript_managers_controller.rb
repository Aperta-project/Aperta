class ManuscriptManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def show
    head :ok
  end

  private

  def paper
    Paper.find_by_short_doi(params[:paper_short_doi])
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end
end
