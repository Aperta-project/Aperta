class UpdateDoisToNewFormat < ActiveRecord::Migration
  def up
    # Adds the word 'journal' to the full doi
    Paper.find_each do |paper|
      if paper.doi && !paper.doi.include?('journal')
        puts "Updating #{paper.doi}..."
        paper.update_column(:doi, paper.doi.split('/').join('/journal.'))
        puts "Updated to #{paper.doi}"
      end
    end
  end

  def down
    Paper.find_each do |paper|
      if paper.doi && paper.doi.include?('journal')
        puts "Updating #{paper.doi}..."
        paper.update_column(:doi, paper.doi.split('journal.').join)
        puts "Updated to #{paper.doi}"
      end
    end
  end
end
