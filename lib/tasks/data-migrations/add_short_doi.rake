namespace :data do
  namespace :migrate do
    namespace :papers do
      desc 'Add short_doi to all papers'
      task add_short_doi_to_papers: :environment do
        Paper.all.each do |p|
          parts = p.doi.split('/').last.split('.')
          p.short_doi = parts[-2] + '.' + parts[-1]
          p.save!
        end
      end
    end
  end
end
