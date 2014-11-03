module StandardTasks
  class FigureTask < Task
    include MetadataTask

    register_task default_title: "Upload Figures", default_role: "author"

    def figure_access_details
      paper.figures.map(&:access_details)
    end
  end
end
