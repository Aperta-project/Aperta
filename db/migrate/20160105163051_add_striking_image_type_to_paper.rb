# A striking image can be a `Figure` or a `SupportingInformationFile`
class AddStrikingImageTypeToPaper < ActiveRecord::Migration
  def up
    add_column :papers, :striking_image_type, :string
    execute <<-SQL
     UPDATE papers SET striking_image_type = 'Figure'
     WHERE striking_image_id IS NOT NULL
    SQL
  end

  def down
    remove_column :papers, :striking_image_type
  end
end
