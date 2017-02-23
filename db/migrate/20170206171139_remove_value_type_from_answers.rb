class RemoveValueTypeFromAnswers < ActiveRecord::Migration
  def change
    remove_column :answers, :value_type, :string
  end
end
