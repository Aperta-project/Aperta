module BillingCard
  class BillingDetail < ActiveRecord::Base
    belongs_to :billing_card_task
  end
end
