class CreateAuthorGroups < ActiveRecord::Migration
  def change
    create_table :author_groups do |t|
      t.string :name
      t.references :paper, index: true
    end
  end
end
