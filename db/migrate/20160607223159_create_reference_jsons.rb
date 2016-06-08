class CreateReferenceJsons < ActiveRecord::Migration
  class ReferenceJson < ActiveRecord::Base
  end

  def up
    create_table :reference_jsons do |t|
      t.text  "name"
      t.jsonb "items", default: [], array: true
      t.timestamps null: false
    end

    Rake::Task['institutional_accounts:add_seed_accounts'].invoke
  end

  def down
    drop_table :reference_jsons
  end
end
