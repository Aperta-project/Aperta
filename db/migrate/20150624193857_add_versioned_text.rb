class AddVersionedText < ActiveRecord::Migration
  def up
    create_table :versioned_texts do |t|
      t.integer :submitting_user_id, :references => [:users, :id]
      t.integer :paper_id, :references => [:paper, :id]
      t.integer :major_version, default: 0
      t.integer :minor_version, default: 0
      t.boolean :active, default: true
      t.boolean :copy_on_edit, default: false
      t.text :text
    end

    execute(<<-statement)
      INSERT INTO versioned_texts
         (text, major_version, copy_on_edit)
      SELECT
         body, 0, publishing_state <> 'ongoing'
      FROM papers
    statement

    remove_column :papers, :body
  end

  def down
    # TODO restore paper bodies
    add_column :papers, :body, :text
    drop_table :versioned_texts
  end
end
