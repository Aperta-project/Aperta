module BillingCard
  class BillingCardTask < Task
    # uncomment the following line if you want to enable event streaming for this model
    # include EventStreamNotifier

    register_task default_title: "Billing", default_role: "author"
    has_one :billing_detail

    def active_model_serializer
      BillingCard::BillingCardTaskSerializer
    end
  end
end
