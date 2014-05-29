class CreateDeclarationSurveys < ActiveRecord::Migration
  def change
    create_table :declaration_surveys do |t|
      t.text    "question", null: false
      t.text    "answer"
      t.integer "task_id"

      t.timestamps
    end
  end
end
