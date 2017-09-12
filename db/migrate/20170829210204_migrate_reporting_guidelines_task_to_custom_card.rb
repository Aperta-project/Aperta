class MigrateReportingGuidelinesTaskToCustomCard < ActiveRecord::Migration
  def up
    # load custom card into the system
    CustomCard::Loader.all

    # migrate legacy task to custom card
    migrator = CustomCard::Migrator.new(legacy_task_klass_name: "TahiStandardTasks::ReportingGuidelinesTask", configuration_class: CustomCard::Configurations::ReportingGuidelines)
    migrator.migrate
  end
end
