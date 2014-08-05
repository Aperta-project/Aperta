class CreateQuestionAttachments < ActiveRecord::Migration
  def change
    create_table :question_attachments do |t|
      t.references :question, index: true
      t.string :attachment
      t.string :title
      t.string :status
      t.timestamps
    end
  end
end
