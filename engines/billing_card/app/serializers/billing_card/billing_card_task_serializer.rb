module BillingCard
  class BillingCardTaskSerializer < ::TaskSerializer
    has_one :billing_detail, embed: :id, include: true
  end
end
