module PaperHelper
  def truncated_title(paper)
    truncate (paper.title || paper.short_title), length: 120, separator: ' '
  end
end
