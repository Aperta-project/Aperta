module TahiStandardTasks
  class FigureTask < Task
    include MetadataTask

    DEFAULT_TITLE = 'Figures'.freeze

    def figure_access_details
      paper.figures.map(&:access_details)
    end
  end
end
