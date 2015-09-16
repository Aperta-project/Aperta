module TahiStandardTasks
  class TaxonTask < ::Task
    include MetadataTask
    register_task default_title: "New Taxon", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(owner_id:nil, owner_type: name, ident: "taxon_zoological", value_type: "boolean", text: "Does this manuscript describe a new zoological taxon name?")
      zoological_complies =  NestedQuestion.new(owner_id:nil, owner_type: name, ident: "complies", value_type: "boolean", text: "All authors comply with the Policies Regarding Submission of a new Taxon Name")
      questions.last.children << zoological_complies

      questions << NestedQuestion.new(owner_id: nil, owner_type: name, ident: "taxon_botanical", value_type: "boolean", text: "Does this manuscript describe a new botantical taxon name?")
      botanical_complies = NestedQuestion.new(owner_id: nil, owner_type: name, ident: "complies", value_type: "boolean", text: "All authors comply with the Policies Regarding Submission of a new Taxon Name")
      questions.last.children << botanical_complies

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
