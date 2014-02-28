class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.string :flows
      t.references :user, index: true

      t.timestamps
    end
  end
end
