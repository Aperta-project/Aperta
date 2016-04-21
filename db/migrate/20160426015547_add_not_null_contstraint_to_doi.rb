# Don't let papers exist without DOIs.
class AddNotNullContstraintToDoi < ActiveRecord::Migration
  def up
    Paper.where(doi: nil).includes(:journal).find_each do |paper|
      paper.update! doi: DoiService.new(journal: paper.journal).next_doi
    end

    change_column :papers, :doi, :text, null: false
  end

  def down
    change_column :papers, :doi, :text
  end
end
