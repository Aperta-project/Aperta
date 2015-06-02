# This migration comes from tahi_standard_tasks (originally 20150602194646)
class CreateCoverLetter < ActiveRecord::Migration
  def change
    create_table :cover_letters do |t|
      t.belongs_to :paper, index: true

      t.text :body

      t.timestamps
    end
  end
end
