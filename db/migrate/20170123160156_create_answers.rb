# Introduces Answers
class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :card_content, index: true, foreign_key: true
      t.references :owner, polymorphic: true
      t.references :paper, index: true, foreign_key: true
      t.string :value
      t.string :value_type
      t.jsonb :additional_data

      t.timestamps null: false
    end
  end
end
