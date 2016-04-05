##
# Start keeping track of document processing status
#
class AddProcessingToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :processing, :boolean, default: false
  end
end
