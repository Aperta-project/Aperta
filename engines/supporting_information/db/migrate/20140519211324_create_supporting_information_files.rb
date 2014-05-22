class CreateSupportingInformationFiles < ActiveRecord::Migration
  def change
    create_table :supporting_information_files do |t|
      t.belongs_to :paper, index: true
      t.string :title
      t.string :caption
      t.string :attachment

      t.timestamps
    end
  end
end
