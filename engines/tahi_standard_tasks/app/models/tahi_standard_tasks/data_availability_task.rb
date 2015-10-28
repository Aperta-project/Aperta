module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    register_task default_title: "Data Availability", default_role: "author"

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
