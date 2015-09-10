class AddKindToEventStore < ActiveRecord::Migration
  def change
    add_column :event_stores, :kind, :string
  end
end
