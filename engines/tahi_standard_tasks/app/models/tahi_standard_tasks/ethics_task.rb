module TahiStandardTasks
  class EthicsTask < Task
    include MetadataTask
    register_task default_title: "Ethics Statement", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "human_subjects", value_type: "boolean", text: "Does your study involve Human Subject Research (human participants and/or tissue)?", children: [
        NestedQuestion.new(owner_id:nil, owner_type: name, ident: "participants", value_type: "text", text: "Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research.")
      ])

      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "animal_subjects", value_type: "boolean", text: "Does your study involve Animal Research (vertebrate animals, embryos or tissues)?", children: [
        NestedQuestion.new(owner_id:nil, owner_type: name, ident: "field_permit", value_type: "text", text: "Please enter your statement below:")
      ])

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
