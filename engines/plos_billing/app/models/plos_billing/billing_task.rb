module PlosBilling
  class BillingTask < ::Task
    include SubmissionTask

    DEFAULT_TITLE = 'Billing'.freeze
    DEFAULT_ROLE_HINT = 'author'.freeze
    REQUIRED_PERMISSIONS = [
      { action: 'view', applies_to: 'PlosBilling::BillingTask' },
      { action: 'edit', applies_to: 'PlosBilling::BillingTask' }
    ].freeze

    def active_model_serializer
      TaskSerializer
    end
  end
end
