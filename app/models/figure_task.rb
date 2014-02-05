class FigureTask < Task
  title "Upload Figures"
  role "author"

  def figure_access_details
    paper.figures.map(&:access_details)
  end

  def assignees
    []
  end
end
