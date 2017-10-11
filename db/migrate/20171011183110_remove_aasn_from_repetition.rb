class RemoveAasnFromRepetition < ActiveRecord::Migration
  def change
    remove_column :repetitions, :lft, :integer
    remove_column :repetitions, :rgt, :integer
  end
end
