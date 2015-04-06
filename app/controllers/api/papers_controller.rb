class Api::PapersController < ApplicationController
  include RestrictAccess
  protect_from_forgery except: :update
  skip_before_action :restrict_access, only: [:fake_render_latex]

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
        epub = EpubConverter.new @paper, current_user, params[:include_original]
        send_data epub.epub_stream.string, filename: epub.file_name, disposition: 'attachment'
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

  def fake_render_latex
    puts params
    render json: { latex_image_url: "http://placekitten.com/g/200/#{300 + rand(50)}" }
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
