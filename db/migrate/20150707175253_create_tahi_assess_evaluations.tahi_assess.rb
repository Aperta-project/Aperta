# This migration comes from tahi_assess (originally 20150622222713)
class CreateTahiAssessEvaluations < ActiveRecord::Migration
  def change
    create_table :tahi_assess_evaluations do |t|
      t.boolean :finished
      t.integer :previous_evaluation_id
      t.integer :paper_id
      t.integer :user_id
      t.integer :version_id
      t.integer :name_disclosure
      t.text :coi_statement
    end
  end
end
