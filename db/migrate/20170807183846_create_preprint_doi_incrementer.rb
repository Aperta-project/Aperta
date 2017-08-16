class CreatePreprintDoiIncrementer < ActiveRecord::Migration
  def change
    create_table :preprint_doi_incrementers do |t|
      t.integer :value, null: false, default: 1
    end
  end
end
