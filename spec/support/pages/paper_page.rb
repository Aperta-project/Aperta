class PaperPage < Page
  path :paper

  def title
    find("#paper-title").text
  end
end
