# :nodoc:
class AddGradualEngagementToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :gradual_engagement, :boolean, default: false
  end
end
