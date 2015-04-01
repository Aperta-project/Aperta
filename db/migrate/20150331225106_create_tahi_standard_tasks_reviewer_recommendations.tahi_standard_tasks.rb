# This migration comes from tahi_standard_tasks (originally 20150331225046)
class CreateTahiStandardTasksReviewerRecommendations < ActiveRecord::Migration
  def change
    create_table :tahi_standard_tasks_reviewer_recommendations do |t|
      t.references :reviewer_recommendations_task
      t.string     :first_name
      t.string     :last_name
      t.string     :middle_initial
      t.string     :email, null: false
      t.string     :department
      t.string     :title
      t.string     :affiliation
      t.string     :recommend_or_oppose, null: false
      t.text       :reason
      t.timestamps
    end
  end
end
