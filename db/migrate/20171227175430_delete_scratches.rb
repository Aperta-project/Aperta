class DeleteScratches < ActiveRecord::Migration
  def up
    drop_table :scratches, if_exists: true
  end
end
