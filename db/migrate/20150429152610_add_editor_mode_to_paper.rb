class AddEditorModeToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :editor_mode, :string, default: "html", null: false
  end
end
