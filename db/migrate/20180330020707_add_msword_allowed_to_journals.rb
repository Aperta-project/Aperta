class AddMswordAllowedToJournals < ActiveRecord::Migration
  def change
    add_column :journals, :msword_allowed, :boolean, null: false, default: false
  end
end
