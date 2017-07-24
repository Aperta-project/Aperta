class AddEditorStyleToCardContents < ActiveRecord::Migration
  def change
    add_column :card_contents, :editor_style, :string
  end
end
