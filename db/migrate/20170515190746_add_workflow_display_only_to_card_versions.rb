# rubocop:disable Style/AndOr, Metrics/LineLength
class AddWorkflowDisplayOnlyToCardVersions < ActiveRecord::Migration
  def change
    add_column :card_versions, :workflow_display_only, :boolean, default: false, null: false
  end
end
# rubocop:enable Style/AndOr, Metrics/LineLength
