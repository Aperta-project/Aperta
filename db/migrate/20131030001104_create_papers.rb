class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :short_title
      t.string :title
      t.text :body
      t.text :abstract

      t.timestamps
    end
  end
end
