class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.references :owner, polymorphic: true
      t.string :name
      t.string :value
      t.string :type

      t.timestamps null: false
    end
  end
end
