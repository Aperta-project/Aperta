module TahiStandardTasks
  class FinancialDisclosureTask < ::Task
    include MetadataTask

    DEFAULT_TITLE = 'Financial Disclosure'
    DEFAULT_ROLE = 'author'

    has_many(
      :funders,
      inverse_of: :task,
      foreign_key: :task_id,
      dependent: :destroy,
    )

    def funding_statement
      statement = funders.map(&:funding_statement).join(";\n")
      if statement.present?
        statement + '.'
      else
        "The author(s) received no specific funding for this work."
      end
    end
  end
end
