module PaperTaskFinders
  def billing_task
    tasks.find_by(type: BillingTask.name)
  end
end
