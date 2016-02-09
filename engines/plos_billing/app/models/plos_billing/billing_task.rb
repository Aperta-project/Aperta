module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    DEFAULT_TITLE = 'Billing'
    DEFAULT_ROLE = 'author'
    REQUIRED_PERMISSIONS = [
      { action: 'view', applies_to: 'PlosBilling::BillingTask' },
      { action: 'edit', applies_to: 'PlosBilling::BillingTask' }
    ]

    def active_model_serializer
      TaskSerializer
    end
  end
end
