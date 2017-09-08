class RemoveActsAsParanoid < ActiveRecord::Migration
  TABLES = %i[answers card_content_validations card_contents card_versions cards].freeze

  def up
    TABLES.each do |table|
      execute "delete from #{table} where deleted_at is not null"
      remove_column table, :deleted_at
    end
  end

  def down
    TABLES.each do |table|
      add_column table, :deleted_at, :timestamp
    end
  end
end
