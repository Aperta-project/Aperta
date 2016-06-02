# rubocop:disable all
namespace :data do
  namespace :migrate do
    namespace :papers do
      desc "Adds the word 'journal' to the full doi"
      task update_dois: :environment do
        Paper.find_each do |paper|
          if paper.doi && !paper.doi.include?('journal')
            puts "Updating #{paper.doi}..."
            paper.update_column(:doi, paper.doi.split('/').join('/journal.'))
            puts "Updated to #{paper.doi}"
          end
        end
      end
    end
  end
end
