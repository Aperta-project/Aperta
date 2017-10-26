class CreateEventBehaviorAttributes < ActiveRecord::Migration
  def change
    create_table :event_behavior_attributes do |t|
      t.references :event_behavior, index: true, null: false
      t.string :name
      t.string :value_type
      t.boolean :boolean_value
      t.integer :integer_value
      t.string :string_value
      t.jsonb :json_value
      t.timestamps null: false
    end
  end
end
