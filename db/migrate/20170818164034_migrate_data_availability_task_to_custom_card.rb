class MigrateDataAvailabilityTaskToCustomCard < ActiveRecord::Migration
  def up
    # load custom card into the system
    CustomCard::Loader.all

    # migrate legacy task to custom card
    migrator = CustomCard::Migrator.new(legacy_task_klass_name: "TahiStandardTasks::DataAvailabilityTask", card_name: "Data Availability")
    migrator.migrate
  end
end
