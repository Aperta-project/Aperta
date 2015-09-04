module PaperTaskFinders
  def billing_card
    tasks.find_by_type("PlosBilling::BillingTask") # TODO: handle possible multiples?
  end
end
