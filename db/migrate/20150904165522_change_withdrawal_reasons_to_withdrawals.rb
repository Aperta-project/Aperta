class ChangeWithdrawalReasonsToWithdrawals < ActiveRecord::Migration
  def up
    add_column      :papers, :withdrawals, :jsonb, array: true, default: []
    remove_column   :papers, :withdrawal_reasons
  end

  def down
    remove_column   :papers, :withdrawals
    add_column      :papers, :withdrawal_reasons, :text, array: true, default: [] 
  end
end
