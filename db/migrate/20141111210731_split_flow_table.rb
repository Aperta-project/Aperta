class SplitFlowTable < ActiveRecord::Migration
  def change

    remove_column :flows, :role_id, :integer

    rename_table :flows, :user_flows

    create_table :role_flows do |t|
      t.string :title
      t.string :empty_text
      t.references :role
    end
  end
end
