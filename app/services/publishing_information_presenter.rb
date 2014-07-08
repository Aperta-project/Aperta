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
    "<h1 id='paper-display-title'>#{paper.display_title}</h1>"
  end

  def journal_name
    "<p id='journal-name'><em>#{paper.journal.name}</em></p>"
  end

  def generated_at
    "<p id='generated-at'><em>#{Date.today.to_s :long}</em></p>"
  end

  def downloader_name
    "Generated for #{downloader.full_name}"
  end
end
