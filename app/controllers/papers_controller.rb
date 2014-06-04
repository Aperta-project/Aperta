class PapersController < ApplicationController
  before_filter :authenticate_user!

  layout 'ember'

  respond_to :json

  def show
    respond_to do |format|
      @paper = PaperFilter.new(params[:id], current_user).paper

      format.html do
        render 'ember/index'
      end

      format.json do
        render json: @paper
      end
    end
  end

  def create
    respond_with PaperFactory.create(paper_params, current_user)
  end

  def edit
    @paper = PaperFilter.new(params[:id], current_user).paper
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
      respond_with @paper
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript = @paper.manuscript || @paper.build_manuscript

    # TODO: we're downloading this once, then using `open` to download it again
    # is there a way to reuse the same file for both?
    manuscript.source.download!(params[:url])
    manuscript.save

    @paper.update OxgarageParser.new(open(manuscript.source.file.url)).to_hash
    head :no_content
  end

  def download
    @paper = PaperFilter.new(params[:id], current_user).paper
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
      authors: [:first_name, :middle_initial, :last_name, :title, :affiliation, :secondary_affiliation, :department, :email, :deceased, :corresponding_author],
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
