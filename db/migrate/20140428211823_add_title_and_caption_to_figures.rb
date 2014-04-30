class AddTitleAndCaptionToFigures < ActiveRecord::Migration
  def change
    add_column :figures, :title, :string
    add_column :figures, :caption, :string
  end
end
