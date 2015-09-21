class AddQuestionTypeToQuestionAttachments < ActiveRecord::Migration
  def up
    add_column :question_attachments, :question_type, :string
    execute <<-SQL
      UPDATE question_attachments
      SET question_type='Question';
    SQL
  end

  def down
    remove_column :question_attachments, :question_type
  end
end
