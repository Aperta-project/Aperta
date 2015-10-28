module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    register_task default_title: "New Taxon", default_role: "author"

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
