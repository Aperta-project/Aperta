class ImproveCardVersions < ActiveRecord::Migration
  def change
    raise 'This migration does not migrate data' unless \
      count('card_versions').zero? &&
          count('card_contents').zero? &&
          count('cards').zero?
    remove_column :card_contents, :card_id
    add_column :card_contents, :card_version_id, :integer
    remove_column :card_versions, :card_content_id
  end

  def count(table_name)
    column_name = "#{table_name}_count"
    sql_result = execute("SELECT COUNT(id) as #{column_name} FROM #{table_name}")
    sql_result.field_values(column_name).first.to_i
  end
end
