namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7826: Stores file type with the paper, either pdf or Word instead of assuming
      that all documents are Word files
    DESC
    task migrate_file_type_to_kind: :environment do
      messages = []
      Paper.find_each do |paper|
        file_type = paper.file.file.file.try(:extension)
        if file_type
          STDOUT.puts("Updating 'kind' column for paper #{paper.id}")
          paper.file.update_column(:kind, file_type)
        else
          if paper.processing && paper.withdrawn?
            messages << "Skipped #{paper.id} because it is stuck in processing"
          else
            if !Rails.env.development?
              fail "Unexpected error for paper #{paper.id} not having a uploaded filetype"
            else
              # Assume a filetype of docx for the papers in development before this point
              paper.file.update_column(:kind, 'docx')
              messages << "Updating paper #{paper.id} to docx filetype in development"
            end
          end
        end
      end

      messages.each { |msg| STDOUT.puts(msg) }
      STDOUT.puts('Data migration completed')
    end
  end

  desc <<-DESC
      APERTA-7826: Stores file type with the paper, either pdf or Word instead of assuming
      that all documents are Word files

      This is intended to be run as part of a down migration that will undo the population of
      the 'kind' column on file.
  DESC
  task :migrate_kind_back_to_nil do
    Paper.find_each do |paper|
      paper.file.update_column(:kind, nil)
    end
  end
end