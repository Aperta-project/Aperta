# This migration comes from tahi_assess (originally 20150402210247)
class CreateAssistants < ActiveRecord::Migration
  def change
    create_table :assess_assistants do |t|
      t.integer :assess_task_id, index: true
      t.string  :first_name
      t.string  :middle_initial
      t.string  :last_name
      t.string  :email
      t.string  :department
      t.string  :title
      t.string  :affiliation
    end
  end
end
