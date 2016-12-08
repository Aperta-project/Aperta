namespace :data do
  namespace :migrate do
    namespace :papers do
      desc <<-DESC.strip_heredoc
        APERTA-7777: Add short_doi to all papers

        This backfills short_doi for all papers that do not have them.
      DESC
      task add_short_doi_to_papers: :environment do
        Paper.reset_column_information
        Paper.all.each do |p|
          # Do not overwrite existing short dois
          next if p.short_doi.present?

          parts = p.doi.split('/').last.split('.')
          p.short_doi = parts[-2] + '.' + parts[-1]
          puts "Adding short_doi to paper #{p.id} #{p.short_doi}"
          p.save!
        end
      end
    end
  end
end
