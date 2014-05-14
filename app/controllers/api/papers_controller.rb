class Api::PapersController < ApplicationController
  protect_from_forgery except: :update

  def index
    @papers = filtered_papers
    render json: @papers, each_serializer: Api::PaperSerializer
  end

  def show
    respond_to do |format|
      @paper = Paper.find params[:id]

      format.json do
        render json: [@paper], each_serializer: Api::PaperSerializer
      end

      format.epub do
        epub = EpubConverter.generate_epub @paper, params[:include_original]
        send_data epub[:stream].string, filename: epub[:file_name], disposition: 'attachment'
      end
    end
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

  def filtered_papers
    if params[:published] == "true"
      Paper.published
    elsif params[:published] == "false"
      Paper.unpublished
    else
      Paper.all
    end
  end
end
