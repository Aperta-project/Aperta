class Api::PapersController < ApplicationController
  def index
    @papers = Paper.all
    render json: @papers, each_serializer: Api::PaperSerializer
  end

  def show
    @paper = Paper.find params[:id]
    render json: [@paper], each_serializer: Api::PaperSerializer
  end

  def update
    head :no_content
  end
end
