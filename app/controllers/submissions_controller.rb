class SubmissionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @paper = Paper.find(params[:paper_id])
  end

  def create
    @paper = Paper.find(params[:paper_id])

    if @paper.update(submitted: true)
      redirect_to root_path, notice: 'Your paper has been submitted to PLOS'
    end
  end
end
