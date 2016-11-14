class ManuscriptManagersController < ApplicationController
  before_action :authenticate_user!

  def show
    requires_user_can(:manage_workflow, paper)
    head :ok
  end

  private

  def paper
    Paper.find(params[:paper_id])
  end

end
