module TahiStandardTasks
  class FinancialDisclosureTask < ::Task
    include MetadataTask
    register_task default_title: "Financial Disclosure", default_role: "author"
    has_many :funders, inverse_of: :task, foreign_key: :task_id

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

  end
end
