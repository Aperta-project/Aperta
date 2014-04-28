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
    path = params["_json"].first["path"].split("/")
    id = params[:id]
    attribute = path.last.underscore

    if attribute.in? allowed_attributes
      Paper.find(id).update_attribute(attribute,
                                      params["_json"].first["value"])
      head :no_content
    else
      head :unauthorized
    end
  end

  private
  def allowed_attributes
    ['published_at']
  end
end
