class MigrateFinancialDisclosureToCustomCard < ActiveRecord::Migration
  def up
    # load custom card into the system
    CustomCard::Loader.all

    # migrate legacy task to custom card
    ActiveRecord::Base.transaction do
      CustomCard::FinancialDisclosureMigrator.new.migrate_all
    end
  end
end
