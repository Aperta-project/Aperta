module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    DEFAULT_TITLE = 'Billing'.freeze
    REQUIRED_PERMISSIONS = [
      { action: 'view', applies_to: 'PlosBilling::BillingTask' },
      { action: 'edit', applies_to: 'PlosBilling::BillingTask' }
    ].freeze

    def active_model_serializer
      TaskSerializer
    end
  end
end
