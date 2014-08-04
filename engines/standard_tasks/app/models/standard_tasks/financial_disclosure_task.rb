module StandardTasks
  class FinancialDisclosureTask < ::Task
    title "Financial Disclosure"
    role "author"
    has_many :funders, inverse_of: :task, foreign_key: :task_id
  end
end
