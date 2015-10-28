module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author"

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def active_model_serializer
      TaskSerializer
    end
  end
end
