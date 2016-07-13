require 'rails/generators/active_record'

class DataMigrationGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    migration_template 'migration.rb', "db/migrate/#{file_name}.rb"
  end
end
