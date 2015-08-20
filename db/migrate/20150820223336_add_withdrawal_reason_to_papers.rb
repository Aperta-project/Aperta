class AddWithdrawalReasonToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :withdrawal_reason, :text
  end
end
