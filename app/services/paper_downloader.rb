class PaperDownloader

  attr_reader :paper

  def initialize(paper)
    @paper = paper
  end

  def body
    if paper.body
      "#{paper_body_with_figures}#{download_supporting_information}"
    end
  end

  private

  def paper_body_with_figures
    paper.body.gsub(/\/attachments\/figures\/(\d+)\?version=detail/) do
      Figure.find($1).attachment.detail.url
    end
  end

  def download_supporting_information
    return if paper.supporting_information_files.empty?

    html_result = "<h2>Supporting Information</h2>"

    paper.supporting_information_files.each do |file|
      if file.preview_src
        html_result.concat "<p>#{file.download_link file.preview_image}</p>"
      end
      html_result.concat "<p>#{file.download_link}</p>"
    end

    html_result
  end
end
