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
  end
end
