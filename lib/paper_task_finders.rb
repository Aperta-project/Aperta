module PaperTaskFinders
  def billing_card
    tasks.find_by_type("PlosBilling::BillingTask") # TODO: handle possible multiples?
  end
  def financial_disclosure
    tasks.find_by_type("TahiStandardTasks::FinancialDisclosureTask")
  end
end
