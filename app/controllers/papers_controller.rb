class PapersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @paper = PaperPolicy.new(params[:id], current_user).paper
    raise ActiveRecord::RecordNotFound unless @paper
    redirect_to edit_paper_path(@paper) unless @paper.submitted?
    @tasks = TaskPolicy.new(@paper, current_user).tasks
  end

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.new(paper_params)

    if @paper.save
      redirect_to edit_paper_path @paper
    else
      render :new
    end
  end

  def edit
    @paper = PaperPolicy.new(params[:id], current_user).paper
    redirect_to paper_path(@paper) if @paper.submitted?
    @tasks = TaskPolicy.new(@paper, current_user).tasks
  end

  def update
    @paper = Paper.find(params[:id])
    params[:paper][:authors] = JSON.parse params[:paper][:authors] if params[:paper].has_key? :authors

    if @paper.update paper_params
      respond_to do |f|
        f.html { redirect_to root_path }
        f.json { head :no_content }
      end
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript_data = OxgarageParser.parse(params[:upload_file].path)
    @paper.update manuscript_data
    redirect_to edit_paper_path(@paper)
  end

  def download
    @paper = Paper.find(params[:id])
    #
    # epub = EeePub.make do |e| e.title       @paper.title
    #   e.creator     @paper.user.full_name
    #   e.publisher   'PLOS'
    #   e.date        Date.today
    #   e.identifier  'http://example.com/book/foo', scheme: 'URL'
    #   e.uid         'http://example.com/book/foo'

    #   e.files [Rails.root.join('hello.html')]
    #   e.nav [
    #     {label: '1. hello', content: 'hello.html'}
    #   ]
    # end
    # epub.save('sample.epub')
    #

    title = @paper.title
    full_name = @paper.user.full_name
    tmp_paper = File.new(Rails.root.join('temp-paper.html'), 'wb')
    html_top = <<-EOD
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
	<title>title</title>
  </head>
  <body>
    EOD
    html_bottom = <<-EOD
  </body>
</html>
    EOD
    html = html_top + @paper.body.force_encoding('UTF-8') + html_bottom
    tmp_paper.write(html)
    puts html

    # stdout, errors, _ = Open3.capture3 "ebook-convert #{tmp_paper.path} sample123.epub"
    # puts stdout
    
    builder = GEPUB::Builder.new {
      language 'en'
      unique_identifier 'http://example.com/hello-world', 'BookID', 'URL'

      title title

      creator full_name 

      date Date.today.to_s

      resources(:workdir => '.') {
        # cover_image 'img/image1.jpg' => 'image1.jpg'
        ordered {
          file tmp_paper.path
          heading 'Chapter 1'
        }
      }
    }

    epubname = File.join(Rails.root.join('example_with_builder.epub'))
    builder.generate_epub(epubname)

    # tmp_paper = File.new(Rails.root.join('temp-paper.html'), 'w')
    # tmp_paper.write(@paper.body)

    # stdout, errors, _ = Open3.capture3 "ebook-convert #{tmp_paper.path} sample123.epub"
    # puts stdout
    send_file Rails.root.join('example_with_builder.epub')
  end

  private

  def paper_params
    params.require(:paper).permit(:short_title, :title, :abstract, :body, :paper_type, :submitted, :journal_id, declarations_attributes: [:id, :answer], authors: [:first_name, :last_name, :affiliation, :email])
  end
end
