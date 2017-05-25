# rubocop:disable Style/AndOr, Metrics/LineLength
class AddWorkflowDisplayOnlyToCards < ActiveRecord::Migration
  def change
    add_column :cards, :workflow_display_only, :boolean, default: false, null: false
  end
end
# rubocop:enable Style/AndOr, Metrics/LineLength
