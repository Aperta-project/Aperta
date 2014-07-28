module StandardTasks
  class FigureTask < Task
    include MetadataTask

    title "Upload Figures"
    role "author"

    def figure_access_details
      paper.figures.map(&:access_details)
    end

    def assignees
      User.none
    end
  end
end
