require "rails/generators/active_record"

module CustomCard
  class MigrationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # CustomCard::Configurations class name (CustomCard::Configurations::MyCard)
    argument :configuration, type: :string, required: true

    # legacy class name ("TahiStandardTasks::CoverLetterTask")
    argument :legacy_task_klass_name, type: :string, required: true

    def generate_custom_card_migration
      migration_template "migration.template", "db/migrate/#{file_name}.rb"
    end

    private

    def file_name
      migration_klass_name.underscore
    end

    def migration_klass_name
      "Migrate#{legacy_task_klass_name.demodulize}ToCustomCard"
    end
  end
end
