class AddAuthorsToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :authors, :text, default: [].to_yaml
  end
end
