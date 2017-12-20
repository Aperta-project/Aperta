class DestroyFinancialDisclosureJtts < ActiveRecord::Migration
  # The previous version of the CustomCard::FinancialDisclosureMigrator only
  # deleted a single JournalTaskType rather than all of them. This migration
  # will clean up the data on the QA machines where that version has already run.
  def up
    JournalTaskType.where(kind: "TahiStandardTasks::FinancialDisclosureTask").delete_all
  end
end
