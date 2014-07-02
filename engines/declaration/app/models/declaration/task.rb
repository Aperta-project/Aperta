module Declaration
  class Task < ::Task
    include MetadataTask

    title "Enter Declarations"
    role "author"

    has_many :surveys,
      -> { order(:id) },
      foreign_key: "task_id",
      inverse_of: :declaration_task,
      dependent: :destroy

    before_create :default_surveys

    DEFAULT_SURVEY_QUESTIONS = [
      "COMPETING INTERESTS: do the authors have any competing interests?",
      "ETHICS STATEMENT: (if applicable) the authors declare the following ethics statement:",
      "FINANCIAL DISCLOSURE: did :he funders have any role in study design, data collection and analysis, decision to publish, or preperation of the manuscript?"
    ]

    def assignees
      User.none
    end

    private

    def default_surveys
      DEFAULT_SURVEY_QUESTIONS.map do |q|
        surveys.build(question: q)
      end
    end
  end
end
