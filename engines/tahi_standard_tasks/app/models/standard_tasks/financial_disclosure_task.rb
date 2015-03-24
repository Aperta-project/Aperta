module StandardTasks
  class FinancialDisclosureTask < ::Task
    register_task default_title: "Financial Disclosure", default_role: "author"
    has_many :funders, inverse_of: :task, foreign_key: :task_id
  end
end
