namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7826: Stores file type with the paper, either pdf, doc or docx instead of assuming
      that all documents are either doc or docx.
    DESC
    task migrate_file_type_on_manuscript_attachment: :environment do
      messages = []
      Paper.find_each do |paper|
        file_type = paper.file.try(:file).try(:file).try(:extension)
        if file_type
          STDOUT.puts("Updating 'file_type' column for paper #{paper.id} to #{file_type}")
          paper.file.update_column(:file_type, file_type.downcase)
        else
          paper_url = Rails.application.routes.url_helpers.paper_url(paper)
          paper_url.slice!('api/')

          if paper.processing && paper.withdrawn?
            messages << "Skipped #{paper_url} (paper id: #{paper.id}) because it is stuck in processing"
          else
            if paper.file
              # Assume a filetype of docx for papers without an uploaded filetype run before this point
              paper.file.update_column(:file_type, 'docx')
              messages << "UNUPLOADED_PAPER: Updating paper #{paper.id} to docx filetype"
            else
              messages << "UNUPLOADED_PAPER: Skipping paper #{paper.id} since there is no uploaded paper"
            end
          end
        end
      end

      messages.each { |msg| STDOUT.puts(msg) }
      STDOUT.puts('Data migration completed')
    end
  end

  desc <<-DESC
      APERTA-7826: This is intended to be run as part of a down migration that will undo the population of
      the 'file_type' column on file.
  DESC
  task :migrate_file_type_back_to_nil do
    ManuscriptAttachment.update_all(file_type: nil)
  end
end
