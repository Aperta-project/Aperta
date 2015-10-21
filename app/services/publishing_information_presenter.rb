class PublishingInformationPresenter
  attr_reader :paper, :downloader

  def initialize(paper, downloader)
    @paper = paper
    @downloader = downloader
  end

  def css
    <<-CSS
      #publishing-information {
        text-align: center;
        height: 100%;
        display: relative;
      }
    CSS
  end

  def html
    <<-HTML
      #{title}
      #{journal_name}
      #{generated_at}
    HTML
  end

  def title
    "<h1 id='paper-display-title'>#{paper.display_title(sanitized: false)}</h1>"
  end

  def journal_name
    "<p id='journal-name'><em>#{CGI.escape_html(paper.journal.name)}</em></p>"
  end

  def generated_at(date=nil)
    date ||= Date.today.to_s(:long)
    "<p id='generated-at'><em>#{CGI.escape_html(date)}</em></p>"
  end

  def downloader_name
    "Generated for #{CGI.escape_html(downloader.full_name)}"
  end
end
