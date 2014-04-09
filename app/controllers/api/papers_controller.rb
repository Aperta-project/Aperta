class Api::PapersController < ApplicationController
  def index
    @papers = Paper.all
    render json: @papers, each_serializer: Api::PaperSerializer
  end
end
