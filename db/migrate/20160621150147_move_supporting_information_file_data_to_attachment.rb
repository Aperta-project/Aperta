# Moves all data in supporting_information_files to the attachments table
# and removes the supporting_information_files table.
class MoveSupportingInformationFileDataToAttachment < ActiveRecord::Migration
  def up
    supporting_information_file_count = count 'supporting_information_files'
    starting_attachment_count = count 'attachments'

    execute <<-SQL
      INSERT INTO attachments
            (old_id, paper_id, owner_id,   owner_type, file,       title, caption, status, token, type,                        s3_dir, created_at, updated_at, publishable, label, category)
      SELECT id,     paper_id, si_task_id, 'Task',     attachment, title, caption, status, token, 'SupportingInformationFile', s3_dir, created_at, updated_at, publishable, label, category
      FROM supporting_information_files
    SQL

    # Unset any owner_type values where there was no corresponding task/owner pulled in from
    # the original data-set. This could be in the above SQL statement, but doing
    # it on its own seemed saner.
    execute <<-SQL
      UPDATE attachments
      SET owner_type=null
      WHERE owner_id IS NULL AND type='SupportingInformationFile'
    SQL

    ending_attachment_count = count 'attachments'
    delta = ending_attachment_count - starting_attachment_count - supporting_information_file_count
    unless delta == 0
      fail "Expected to move all the supporting_information_files to the attachments table, but was off by #{delta}"
    end

    drop_table :supporting_information_files
  end

  def down
    create_table "supporting_information_files" do |t|
      t.integer  "paper_id"
      t.string   "title"
      t.string   "caption"
      t.string   "attachment"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status",      default: "processing"
      t.boolean  "publishable", default: true
      t.string   "token"
      t.string   "label"
      t.string   "category"
      t.integer  "si_task_id"
      t.text     "s3_dir"
    end

    execute <<-SQL
      INSERT INTO supporting_information_files
            (id,     paper_id, title, caption, attachment, created_at, updated_at, status, publishable, token, label, category, si_task_id, s3_dir)
      SELECT old_id, paper_id, title, caption, file,       created_at, updated_at, status, publishable, token, label, category, owner_id,   s3_dir
      FROM attachments
      WHERE type='SupportingInformationFile'
    SQL

    add_index "supporting_information_files", ["paper_id"], name: "index_supporting_information_files_on_paper_id", using: :btree
    add_index "supporting_information_files", ["si_task_id"], name: "index_supporting_information_files_on_si_task_id", using: :btree
    add_index "supporting_information_files", ["token"], name: "index_supporting_information_files_on_token", unique: true, using: :btree

    execute <<-SQL
      DELETE FROM attachments
      WHERE type='SupportingInformationFile'
    SQL
  end

  private

  def count(table_name)
    column_name = "#{table_name}_count"
    sql_result = execute("SELECT COUNT(*) as #{column_name} FROM #{table_name}")
    sql_result.field_values(column_name).first.to_i
  end
end
