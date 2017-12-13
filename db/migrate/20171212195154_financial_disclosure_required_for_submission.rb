class FinancialDisclosureRequiredForSubmission < ActiveRecord::Migration
  def up
    toggle_required(true)
  end

  def down
    toggle_required(false)
  end

  # Update this field on any machines that have already run the original
  # CustomCard::FinancialDisclosureMigrator
  def toggle_required(r)
    CardVersion.joins(:card).where(cards: { name: "Financial Disclosure" }).find_each do |cv|
      cv.update!(required_for_submission: r)
    end
  end
end
