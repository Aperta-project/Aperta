module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author"

    def active_model_serializer
      TaskSerializer
    end
  end
end
