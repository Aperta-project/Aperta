class CreateMessageTasks < ActiveRecord::Migration
  def change
    create_table :message_participants do |t|
      t.timestamps
    end

    add_reference :message_participants, :task, index: true
    add_reference :message_participants, :participant, index: true

    create_table :comments do |t|
      t.text :body
      t.timestamps
    end
    add_reference :comments, :commenter, index: true
    add_reference :comments, :task, index: true


    add_column :tasks, :message_subject, :string
  end
end
