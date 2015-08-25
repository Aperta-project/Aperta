class AddWithdrawalReasonsToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :withdrawal_reasons, :text, array: true, default: []
  end
end
