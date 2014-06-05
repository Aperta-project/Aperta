module StandardTasks
  class FigureTask < Task
    include MetadataTask

    title "Upload Figures"
    role "author"

    def figure_access_details
      paper.figures.map(&:access_details)
    end

    def assignees
      []
    end

    def active_model_serializer
      FigureTaskSerializer
    end
  end
end
