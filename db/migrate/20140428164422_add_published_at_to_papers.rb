class AddPublishedAtToPapers < ActiveRecord::Migration
  def change
    add_column :papers, :published_at, :datetime
  end
end
