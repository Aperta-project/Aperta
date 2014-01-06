class CreatePaperReviews < ActiveRecord::Migration
  def change
    create_table :paper_reviews do |t|
      t.belongs_to :task, index: true
      t.text :body

      t.timestamps
    end
  end
end
