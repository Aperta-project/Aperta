module TahiStandardTasks
  class FinancialDisclosureTask < ::Task
    include MetadataTask

    DEFAULT_TITLE = 'Financial Disclosure'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze

    has_many(
      :funders,
      inverse_of: :task,
      foreign_key: :task_id,
      dependent: :destroy
    )
  end
end
