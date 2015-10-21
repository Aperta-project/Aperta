module TahiStandardTasks
  class CompetingInterestsTask < ::Task
    include MetadataTask
    register_task default_title: "Competing Interests", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "competing_interests",
        value_type: "boolean",
        text: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://www.plosbiology.org/static/policies#competing'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
        position: 1
      )

      statement = NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "statement",
        value_type: "text",
        text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
        position: 2
      )
      questions.last.children << statement

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end
  end
end
