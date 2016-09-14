class RemoveBibitems < ActiveRecord::Migration
  def change
    drop_table :bibitems
  end
end
