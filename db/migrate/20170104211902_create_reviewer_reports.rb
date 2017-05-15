class CreateReviewerReports < ActiveRecord::Migration
  def change
    create_table :reviewer_reports do |t|
      t.belongs_to :task, index: true, null: false
      t.belongs_to :decision, null: false
      t.belongs_to :user

      t.timestamps
    end
  end
end
