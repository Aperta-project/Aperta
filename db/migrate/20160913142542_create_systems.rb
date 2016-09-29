# This creates a systems table and a single record that represents
# the System. This is to support the data-driven R&P / authorization
# subsystem.
class CreateSystems < ActiveRecord::Migration
  def up
    create_table :systems do |t|
      t.string :description
      t.timestamps null: false
    end

    execute <<-SQL
      INSERT INTO systems (description, created_at, updated_at) VALUES(
        'The System record represents the application for authorization / R&P work.',
        NOW(),
        NOW()
      );
    SQL
  end

  def down
    drop_table :systems
  end
end
