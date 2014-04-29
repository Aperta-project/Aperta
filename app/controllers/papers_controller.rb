class PapersController < ApplicationController
  before_filter :authenticate_user!

  layout 'ember'

  def show
    respond_to do |format|
      @paper = PaperPolicy.new(params[:id], current_user).paper
      raise ActiveRecord::RecordNotFound unless @paper

      format.html do
        redirect_to edit_paper_path(@paper) unless @paper.submitted?
        @tasks = TaskPolicy.new(@paper, current_user).tasks
      end

      format.json do
        render json: @paper
      end
    end
  end

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.create!(paper_params)
    render status: 201, json: @paper
  end

  def edit
    @paper = PaperPolicy.new(params[:id], current_user).paper
    if @paper.submitted?
      redirect_to paper_path(@paper) and return
    end
    @tasks = TaskPolicy.new(@paper, current_user).tasks

    render 'ember/index'
  end

  def update
    @paper = Paper.find(params[:id])

    if @paper.update(paper_params)
      head 204
    else
      # Ember doesn't re-render the paper if there is an error.
      # e.g. Fails to update on adding new authors, but new authors stay in
      # memory client side even though they aren't persisted in the DB.
      render status: 500
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript_data = OxgarageParser.parse(params[:upload_file].path)
    @paper.update manuscript_data
    head :no_content
  end

  def download
    @paper = PaperPolicy.new(params[:id], current_user).paper
    respond_to do |format|
      format.html do
        epub = EpubConverter.generate_epub @paper
        send_data epub[:stream].string, filename: epub[:file_name], disposition: 'attachment'
      end

      format.pdf do
        send_data PDFKit.new(html_pdf @paper).to_pdf,
          filename: @paper.display_title.parameterize("_"),
          type: 'application/pdf',
          disposition: 'attachment'
      end
    end
  end

  private

  def paper_params
    params.require(:paper).permit(
      :short_title, :title, :abstract,
      :body, :paper_type, :submitted,
      :journal_id,
      authors: [:first_name, :last_name, :affiliation, :email],
      declaration_ids: [],
      reviewer_ids: [],
      phase_ids: [],
      assignee_ids: [],
      editor_ids: [],
      figure_ids: []
    )
  end

  def html_pdf(paper)
    <<-HTML
      <html>
        <head>
          <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
        </head>
        <body>
          <h1>#{paper.display_title}</h1>
          #{paper.body}
        </body>
      </html>
    HTML
  end
end
