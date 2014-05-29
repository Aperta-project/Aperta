class DropSurveys < ActiveRecord::Migration
  def up
    drop_table :surveys
  end

  def down
    create_table "surveys" do |t|
      t.text    "question", null: false
      t.text    "answer"
      t.integer "task_id"
    end
  end
end
