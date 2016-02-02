module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author",
      required_permissions: [
        { action: 'view', applies_to: 'PlosBilling::BillingTask' }
      ]

    def active_model_serializer
      TaskSerializer
    end
  end
end
