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
      statement = funders.map do |funder|
        "#{funder.funding_statement}"
      end

      if !statement.empty?
        statement.join("\n")
      else
        "The author(s) received no specific funding for this work."
      end
    end
  end
end
