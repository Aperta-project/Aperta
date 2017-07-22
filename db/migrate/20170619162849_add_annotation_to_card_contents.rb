class AddAnnotationToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :allow_annotations, :boolean
  end
end
