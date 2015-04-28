class AddRevisionNumberToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :revision_number, :integer, default: 0
  end
end
