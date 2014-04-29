class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def new
    @paper = Paper.find(params[:paper_id])
  end

  def create
    @paper = Paper.find(params[:paper_id])
    if @paper.update_attributes!(submitted: true)
      redirect_to root_path, notice: 'Your paper has been submitted to PLOS'
    else
      respond_with @paper
    end
  end
end
