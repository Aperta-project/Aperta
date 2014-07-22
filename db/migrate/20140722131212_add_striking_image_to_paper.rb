class AddStrikingImageToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :striking_image_id, :integer
  end
end
