module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    register_task default_title: "Billing", default_role: "author",
      required_permission_action: 'view',
      required_permission_applies_to: 'PlosBilling::BillingTask'

    def active_model_serializer
      TaskSerializer
    end
  end
end
