class ChangeCaptionTypeInFigures < ActiveRecord::Migration
  def change
    change_column :figures, :caption, :text
  end
end
