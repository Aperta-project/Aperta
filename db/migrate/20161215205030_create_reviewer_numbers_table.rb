class CreateReviewerNumbersTable < ActiveRecord::Migration
  def change
    create_table :reviewer_numbers do |t|
      t.belongs_to :paper, index: true, null: false
      t.belongs_to :user, index: true, null: false
      t.integer :number

      t.timestamps
    end

    add_index(:reviewer_numbers, [:paper_id, :user_id], unique: true)
    add_index(:reviewer_numbers, [:paper_id, :number], unique: true)
  end
end
