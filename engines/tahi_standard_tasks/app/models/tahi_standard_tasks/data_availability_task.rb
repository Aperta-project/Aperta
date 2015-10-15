module TahiStandardTasks
  class DataAvailabilityTask < ::Task
    include MetadataTask
    register_task default_title: "Data Availability", default_role: "author"

    def self.nested_questions
      questions = []
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "data_fully_available",
        value_type: "boolean",
        text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?",
        position: 1
      )
      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "data_location",
        value_type: "text",
        text: "Please describe where your data may be found, writing in full sentences.",
        position: 2
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
