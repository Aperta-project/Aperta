module TahiStandardTasks
  class ReportingGuidelinesTask < ::Task
    include MetadataTask
    register_task default_title: "Reporting Guidelines", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "clinical_trial", value_type: "boolean", text: "Clinical Trial")

      questions <<  NestedQuestion.new(owner_id:nil, owner_type: name, ident: "systematic_reviews", value_type: "boolean", text: "Systematic Reviews")
      questions.last.children << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "checklist", value_type: "attachment", text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.")

      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "meta_analyses", value_type: "boolean", text: "Meta-analyses")
      questions.last.children << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "checklist", value_type: "attachment", text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.")

      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "diagnostic_studies", value_type: "boolean", text: "Diagnostic studies")
      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "epidemiological_studies", value_type: "boolean", text: "Epidemiological studies")
      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "microarray_studies", value_type: "boolean", text: "Microarray studies")

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

  end
end
