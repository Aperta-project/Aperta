class AddSubmittedToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :submitted, :boolean, default: false, null: false
  end
end
