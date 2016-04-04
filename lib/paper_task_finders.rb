module PaperTaskFinders
  def billing_task
    tasks.find_by(type: PlosBilling::BillingTask.name)
  end

  def financial_disclosure_task
    tasks.find_by(type: TahiStandardTasks::FinancialDisclosureTask.name)
  end
end
