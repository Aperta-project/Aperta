class CreateWithdrawals < ActiveRecord::Migration
  class Paper < ActiveRecord::Base
    serialize :withdrawals, ArrayHashSerializer
  end

  class Withdrawal < ActiveRecord::Base
  end

  def up
    create_table :withdrawals do |t|
      t.string :reason
      t.integer :paper_id, null: false
      t.integer :withdrawn_by_user_id
      t.string :previous_publishing_state, null: false
      t.boolean :previous_editable, null: false, default: true

      t.timestamps null: false
    end

    add_index :withdrawals, :paper_id

    Paper.reset_column_information
    Withdrawal.reset_column_information

    Paper.all.each do |paper|
      paper.withdrawals.each do |withdrawal_hash|
        Withdrawal.create!(
          paper_id: paper.id,
          reason: withdrawal_hash[:reason],
          previous_publishing_state: withdrawal_hash[:previous_publishing_state],
          previous_editable: withdrawal_hash[:previous_editable]
        )
      end
    end

    remove_column :papers, :withdrawals
  end

  def down
    add_column :papers, :withdrawals, :jsonb, array: true, default: []

    Paper.reset_column_information
    Withdrawal.reset_column_information

    Withdrawal.all.each do |withdrawal|
      paper = Paper.find(withdrawal.paper_id)
      paper.withdrawals << {
        previous_publishing_state: withdrawal.previous_publishing_state,
        previous_editable: withdrawal.previous_editable,
        reason: withdrawal.reason,
        withdrawn_by_user_id: withdrawal.withdrawn_by_user_id
      }
      paper.save!
    end

    drop_table :withdrawals
  end
end
