class CreateCredentialsTable < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :provider
      t.string :uid
      t.integer :user_id
    end

    add_index :credentials, [:uid, :provider]

    remove_column :users, :provider
    remove_column :users, :uid
  end
end
