class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email, index: true
      t.string :code, index: { unique: true }
      t.belongs_to :task, index: true
      t.belongs_to :invitee, index: true
      t.belongs_to :actor, index: true
      t.string :state

      t.timestamps null: false
    end
  end
end
