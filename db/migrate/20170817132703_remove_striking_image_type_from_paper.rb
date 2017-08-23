class RemoveStrikingImageTypeFromPaper < ActiveRecord::Migration
  def change
    remove_column :papers, :striking_image_type, :string
    remove_column :papers, :striking_image_id, :integer
  end
end
