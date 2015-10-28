module TahiStandardTasks
  class FigureTask < Task
    include MetadataTask

    register_task default_title: "Figures", default_role: "author"

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def figure_access_details
      paper.figures.map(&:access_details)
    end
  end
end
