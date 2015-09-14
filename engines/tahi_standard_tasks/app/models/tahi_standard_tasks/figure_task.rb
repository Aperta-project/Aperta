module TahiStandardTasks
  class FigureTask < Task
    include MetadataTask

    register_task default_title: "Figures", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "figure_complies",
        value_type: "boolean",
        text: "Yes - I confirm our figures comply with the guidelines."
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def figure_access_details
      paper.figures.map(&:access_details)
    end
  end
end
