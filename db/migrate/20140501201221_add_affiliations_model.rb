class AddAffiliationsModel < ActiveRecord::Migration
  def change
    remove_column :users, :affiliation, :string

    create_table :affiliations do |t|
      t.integer :user_id
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :affiliations, :user_id
  end
end
