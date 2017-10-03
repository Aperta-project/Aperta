class RemoveActsAsParanoidPhase1 < ActiveRecord::Migration
  TABLES = %i[answers card_content_validations card_contents card_versions cards].freeze

  def up
    execute "delete from permissions where filter_by_card_id in (select id from cards where deleted_at is not null)"

    TABLES.each do |table|
      execute "delete from #{table} where deleted_at is not null"
    end
  end

  def down
  end
end
