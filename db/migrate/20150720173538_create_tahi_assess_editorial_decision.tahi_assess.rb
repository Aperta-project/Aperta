# This migration comes from tahi_assess (originally 20150717171650)
class CreateTahiAssessEditorialDecision < ActiveRecord::Migration
  def change
    create_table :tahi_assess_editorial_decisions do |t|
      t.integer :decision_id, null: false
      t.integer :paper_id, null: false
      t.integer :user_id, null: false
      t.boolean :finished, default: false
      t.string  :recommendation
      t.string  :comments

      t.timestamps
    end
  end
end
