class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :question
      t.string :answer
      t.string :ident, index: true
      t.references :task, index: true
      t.json :additional_data
    end
  end
end
