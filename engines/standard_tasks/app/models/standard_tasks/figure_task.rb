module StandardTasks
  class FigureTask < Task
    include MetadataTask

    title "Upload Figures"
    role "author"

    has_many :figures, class_name: "StandardTasks::Figure", foreign_key: :task_id, inverse_of: :figure_task

    def figure_access_details
      figures.map(&:access_details)
    end

    def assignees
      []
    end

    def active_model_serializer
      FigureTaskSerializer
    end
  end
end
