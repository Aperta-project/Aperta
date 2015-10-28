module TahiStandardTasks
  class EthicsTask < Task
    include MetadataTask
    register_task default_title: "Ethics Statement", default_role: "author"

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
