module TahiStandardTasks
  class FinancialDisclosureTask < ::Task
    include MetadataTask
    register_task default_title: "Financial Disclosure", default_role: "author"
    has_many :funders, inverse_of: :task, foreign_key: :task_id

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "author_received_funding",
        value_type: "boolean",
        text: "Did any of the authors receive specific funding for this work?"
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

  end
end
