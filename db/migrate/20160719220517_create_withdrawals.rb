# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
