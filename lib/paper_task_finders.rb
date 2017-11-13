module PaperTaskFinders
  def billing_task
    tasks.find_by(type: PlosBilling::BillingTask.name)
  end
end
