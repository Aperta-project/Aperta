module PaperHelper
  def truncated_title(paper)
    truncate paper.display_title, length: 110, separator: ' '
  end
end
